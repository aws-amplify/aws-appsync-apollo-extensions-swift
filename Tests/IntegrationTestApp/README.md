# Integration Tests

The backend is provisioned with Amplify CLI (Gen2). Follow the Amplify Data documentation to familiarize with the data modeling experience (https://docs.amplify.aws/swift/build-a-backend/data/set-up-data/)

The schema used in `data/resource.ts`

```
import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

const schema = a.schema({
  Todo: a
    .model({
      content: a.string(),
    })
    .authorization(allow => [
      // Allow anyone auth'd with an API key to read everyone's posts.
      allow.publicApiKey(),
      // Allow signed-in user to create, read, update,
      // and delete their __OWN__ posts.
      allow.owner(),
      allow.authenticated('identityPool')
    ])
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'iam',
    apiKeyAuthorizationMode: {
      expiresInDays: 365
    }
  },
});
```

Update `auth/resource.ts`

```
import { defineAuth, defineFunction } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: true,
  },
  triggers: {
    // configure a trigger to point to a function definition
    preSignUp: defineFunction({
      entry: './pre-sign-up-handler.ts'
    })
  }
});

```

Add `auth/pre-sign-up-handler.ts`

```ts
import type { PreSignUpTriggerHandler } from 'aws-lambda';

export const handler: PreSignUpTriggerHandler = async (event) => {
  // your code here
  event.response.autoConfirmUser = true
  return event;
};
```


Update `backend.ts`

```ts
import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';

/**
 * @see https://docs.amplify.aws/react/build-a-backend/ to add storage, functions, and more
 */
const backend = defineBackend({
  auth,
  data,
});

// Override sign in with username as the username

const { cfnUserPool } = backend.auth.resources.cfnResources
cfnUserPool.usernameAttributes = []

cfnUserPool.addPropertyOverride(
  "Policies",
  {
    PasswordPolicy: {
      MinimumLength: 10,
      RequireLowercase: false,
      RequireNumbers: true,
      RequireSymbols: true,
      RequireUppercase: true,
      TemporaryPasswordValidityDays: 20,
    },
  }
);

```

Run `npx ampx sandbox` to deploy your backend.

Once deployed, copy the `amplify_outputs.json` over to IntegrationTestApp folder (Tests/IntegrationTestApp/IntegrationTestApp).

## Generating AppSyncAPI

AppSyncAPI contains the GraphQL operations in Swift, used with the Apollo client. They have been generated and checked in. If these need to be changed or updated, use the Apollo iOS CLI to regenerate them.

1. Download the pre-built binary from https://www.apollographql.com/docs/ios/code-generation/codegen-cli/#installation

2. run `./apollo-ios-cli generate`