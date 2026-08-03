'use strict';

const cliRoot = `${process.env.APPDATA}/npm/node_modules/firebase-tools/lib`;
const { configstore } = require(`${cliRoot}/configstore.js`);
const auth = require(`${cliRoot}/auth.js`);

const projectId = 'library-managment-6bf3f';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
const apply = process.argv.includes('--apply');

async function token() {
  const refreshToken = configstore.get('tokens')?.refresh_token;
  if (!refreshToken) throw new Error('Firebase CLI is not authenticated.');
  return (await auth.getAccessToken(refreshToken, [])).access_token;
}

async function request(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${await token()}`,
      'Content-Type': 'application/json',
      'x-goog-user-project': projectId,
      ...options.headers,
    },
  });
  if (!response.ok) throw new Error(`${response.status}: ${await response.text()}`);
  return response.status === 204 ? null : response.json();
}

async function list(parent, collection) {
  const result = await request(`${base}/${parent ? `${parent}/` : ''}${collection}?pageSize=300`);
  return result.documents || [];
}

const value = (document, field) => {
  const raw = document.fields?.[field];
  return raw?.stringValue ?? raw?.booleanValue ?? null;
};

async function releaseSeat(path, seatNumber) {
  const fields = {
    seatNumber: { stringValue: seatNumber },
    status: { stringValue: 'available' },
    studentId: { nullValue: null },
    studentName: { nullValue: null },
    studentPhone: { nullValue: null },
    shift: { nullValue: null },
    assignedDate: { nullValue: null },
    expiryDate: { nullValue: null },
  };
  if (!apply) return;
  const query = new URLSearchParams();
  for (const field of Object.keys(fields)) query.append('updateMask.fieldPaths', field);
  await request(`${base}/${path}?${query}`, {
    method: 'PATCH',
    body: JSON.stringify({ fields }),
  });
}

async function main() {
  let stale = 0;
  for (const user of await list('', 'users')) {
    const uid = user.name.split('/').at(-1);
    for (const library of await list(`users/${uid}`, 'libraries')) {
      const libraryId = library.name.split('/').at(-1);
      const root = `users/${uid}/libraries/${libraryId}`;
      const students = await list(root, 'students');
      const deletedIds = new Set(
        students.filter((student) => value(student, 'isDeleted') === true).map((student) => student.name.split('/').at(-1)),
      );
      for (const seat of await list(root, 'seats')) {
        const studentId = value(seat, 'studentId');
        if (!studentId || !deletedIds.has(studentId)) continue;
        const seatNumber = seat.name.split('/').at(-1);
        console.log(`${apply ? 'RELEASE' : 'WOULD RELEASE'} ${root}/seats/${seatNumber}`);
        await releaseSeat(`${root}/seats/${seatNumber}`, seatNumber);
        stale++;
      }
    }
  }
  console.log(`${apply ? 'Released' : 'Found'} ${stale} stale occupied seat(s).`);
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
