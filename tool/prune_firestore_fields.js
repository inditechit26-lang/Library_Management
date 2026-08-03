/*
 * Prunes legacy root fields while preserving the approved SaaS schema maps.
 * Uses the currently authenticated Firebase CLI account.
 *
 * Dry run: node tool/prune_firestore_fields.js
 * Apply:   node tool/prune_firestore_fields.js --apply
 */
'use strict';

const cliRoot = `${process.env.APPDATA}/npm/node_modules/firebase-tools/lib`;
const { configstore } = require(`${cliRoot}/configstore.js`);
const auth = require(`${cliRoot}/auth.js`);

const projectId = 'library-managment-6bf3f';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
const apply = process.argv.includes('--apply');
const verbose = process.argv.includes('--verbose');

const userFields = new Set(['profile', 'currentLibraryId']);
const libraryFields = new Set([
  'libraryInfo',
  'branding',
  'configuration',
  'templates',
]);

const nestedFields = {
  profile: new Set([
    'displayName', 'email', 'phone', 'photoUrl', 'emailVerified', 'role',
    'createdAt', 'updatedAt', 'verificationCompletedAt',
  ]),
  libraryInfo: new Set([
    'name', 'ownerName', 'email', 'phone', 'branchName', 'address',
    'openingTime', 'closingTime',
  ]),
  branding: new Set(['logoUrl']),
  configuration: new Set([
    'totalSeats', 'subscriptionPlan', 'libraryConfiguration',
    'paymentSettings', 'plans',
  ]),
  templates: new Set(['membershipRenewal']),
};

async function accessToken() {
  const refreshToken = configstore.get('tokens')?.refresh_token;
  if (!refreshToken) throw new Error('Firebase CLI is not authenticated.');
  return (await auth.getAccessToken(refreshToken, [])).access_token;
}

async function request(url, options = {}) {
  const token = await accessToken();
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'x-goog-user-project': projectId,
      ...options.headers,
    },
  });
  if (!response.ok) throw new Error(`${response.status}: ${await response.text()}`);
  return response.status === 204 ? null : response.json();
}

async function listDocuments(parent, collectionId) {
  const documents = [];
  let pageToken = '';
  do {
    const query = new URLSearchParams({ pageSize: '300' });
    if (pageToken) query.set('pageToken', pageToken);
    const result = await request(`${base}/${parent ? `${parent}/` : ''}${collectionId}?${query}`);
    documents.push(...(result.documents || []));
    pageToken = result.nextPageToken || '';
  } while (pageToken);
  return documents;
}

async function prune(document, allowed) {
  const current = Object.keys(document.fields || {});
  const removed = current.filter((field) => !allowed.has(field));
  const keptFields = Object.fromEntries(
    Object.entries(document.fields || {}).filter(([field]) => allowed.has(field)),
  );
  for (const [field, value] of Object.entries(keptFields)) {
    const nestedAllowed = nestedFields[field];
    const fields = value?.mapValue?.fields;
    if (!nestedAllowed || !fields) continue;
    const nestedRemoved = Object.keys(fields).filter((key) => !nestedAllowed.has(key));
    for (const key of nestedRemoved) delete fields[key];
    removed.push(...nestedRemoved.map((key) => `${field}.${key}`));
  }
  if (!removed.length) return 0;
  console.log(`${apply ? 'PRUNE' : 'WOULD PRUNE'} ${document.name.split('/documents/')[1]}`);
  console.log(`  remove: ${removed.join(', ')}`);
  if (!apply) return removed.length;

  const query = new URLSearchParams();
  for (const field of current) query.append('updateMask.fieldPaths', field);
  await request(`${base}/${document.name.split('/documents/')[1]}?${query}`, {
    method: 'PATCH',
    body: JSON.stringify({ fields: keptFields }),
  });
  return removed.length;
}

async function main() {
  const users = await listDocuments('', 'users');
  let removed = 0;
  for (const user of users) {
    const uid = user.name.split('/').at(-1);
    const libraries = await listDocuments(`users/${uid}`, 'libraries');
    if (verbose) console.log(`USER ${uid}: ${libraries.length} librar${libraries.length === 1 ? 'y' : 'ies'}`);
    removed += await prune(user, userFields);
    for (const library of libraries) removed += await prune(library, libraryFields);
  }
  console.log(`${apply ? 'Removed' : 'Found'} ${removed} extra root field(s) across ${users.length} user(s).`);
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
