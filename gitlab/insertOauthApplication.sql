INSERT INTO oauth_applications (name, uid, secret, redirect_uri, scopes, created_at, updated_at, owner_id, owner_type)
VALUES (
    'Gitpod',
    '<clientId>',
    '<clientSecret>',
    'https://gitpod.<domain>/auth/gitlab/callback',
    'api read_user read_repository',
    now(), now(), 1, 'User'
);