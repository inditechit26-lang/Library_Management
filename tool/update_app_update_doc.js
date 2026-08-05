'use strict';

const cliRoot = `${process.env.APPDATA}/npm/node_modules/firebase-tools/lib`;
const { configstore } = require(`${cliRoot}/configstore.js`);
const auth = require(`${cliRoot}/auth.js`);

const projectId = 'library-managment-6bf3f';
const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

async function accessToken() {
  const refreshToken = configstore.get('tokens')?.refresh_token;
  if (!refreshToken) throw new Error('Firebase CLI is not authenticated.');
  return (await auth.getAccessToken(refreshToken, [])).access_token;
}

async function updateAppUpdateDocument() {
  const token = await accessToken();
  
  const updateData = {
    fields: {
      enabled: { booleanValue: true },
      latestVersion: { stringValue: '1.0.1' },
      minimumSupportedVersion: { stringValue: '1.0.0' },
      releaseDate: { stringValue: new Date().toISOString() },
      apkUrl: { stringValue: 'https://raw.githubusercontent.com/inditechit26-lang/Library_Management/main/app-release.apk' },
      apkSize: { stringValue: '67.1 MB' },
      forceUpdate: { booleanValue: false }
    }
  };

  const response = await fetch(`${base}/appUpdate/android`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'x-goog-user-project': projectId,
    },
    body: JSON.stringify(updateData)
  });

  if (!response.ok) {
    const err = await response.text();
    console.error('Failed to update document:', response.status, err);
    process.exit(1);
  }

  const result = await response.json();
  console.log('Successfully updated appUpdate/android document:');
  console.log(JSON.stringify(result, null, 2));
}

updateAppUpdateDocument().catch(console.error);
