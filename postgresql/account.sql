CREATE SCHEMA IF NOT EXISTS account;

BEGIN;
CREATE TABLE account.accounts (
    id UUID DEFAULT uuidv7() NOT NULL,
    _hash TEXT NOT NULL,
    _salt TEXT NOT NULL,
    _status VARCHAR(50) NOT NULL,
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (id)
);

CREATE INDEX ix_account_created_at
ON account.accounts(_created_at DESC);

CREATE INDEX ix_users_status
ON account.accounts (_status);


COMMENT ON TABLE account.accounts IS '계정 테이블';

COMMENT ON COLUMN account.accounts.id IS '계정 테이블 PK';
COMMENT ON COLUMN account.accounts._hash IS '비밀번호 해시';
COMMENT ON COLUMN account.accounts._salt IS '비밀번호 솔트';
COMMENT ON COLUMN account.accounts._status IS '계정 상태, core.codes - USER_STATUS';
COMMIT;
------------------------------------------------------------
BEGIN;
CREATE TABLE account.account_oauths (
    id UUID DEFAULT uuidv7() NOT NULL,
    user_id UUID NOT NULL,
    _provider VARCHAR(50) NOT NULL,
    _access_token TEXT NOT NULL,
    _refresh_token TEXT NOT NULL,
    _expired_at TIMESTAMPTZ NOT NULL,
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (id),

    FOREIGN KEY (user_id)
    REFERENCES account.accounts(id)
    ON DELETE CASCADE
);

COMMENT ON TABLE account.account_oauths IS '계정 OAuth 테이블';

COMMENT ON COLUMN account.account_oauths.id IS '계정 OAuth 테이블 PK';
COMMENT ON COLUMN account.account_oauths.user_id IS '계정 테이블 FK';
COMMENT ON COLUMN account.account_oauths._provider IS 'OAuth 제공처, core.codes - OAUTH_PROVIDER';
COMMENT ON COLUMN account.account_oauths._access_token IS '엑세스 토큰';
COMMENT ON COLUMN account.account_oauths._refresh_token IS '리프레시 토큰';
COMMENT ON COLUMN account.account_oauths._expired_at IS '만료일자';
COMMIT;
------------------------------------------------------------


/* \
profile.user_profiles (프로필 N)
CREATE TABLE profile.user_profiles (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id      UUID NOT NULL,
    profile_type VARCHAR(30) NOT NULL,
    nickname     VARCHAR(100),
    avatar_url   TEXT,
    bio          TEXT,
    extra        JSONB DEFAULT '{}'::jsonb,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (user_id, profile_type),

    FOREIGN KEY (user_id)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
);
JSONB 인덱스
CREATE INDEX ix_profiles_extra
ON profile.user_profiles
USING GIN (extra);
4️⃣ private.user_privacies (개인정보 1)

민감정보 분리

CREATE TABLE private.user_privacies (
    user_id      UUID PRIMARY KEY,
    real_name    VARCHAR(100),
    phone_number VARCHAR(30),
    birth_date   DATE,
    ci_hash      TEXT,
    address      TEXT,
    created_at   TIMESTAMPTZ DEFAULT now(),

    FOREIGN KEY (user_id)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
);

👉 실무에선 암호화 권장 (pgcrypto)

5️⃣ billing.user_payment_methods (결제수단 N)
CREATE TABLE billing.user_payment_methods (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id     UUID NOT NULL,
    method_type VARCHAR(20) NOT NULL, -- card, bank
    pg_provider VARCHAR(50) NOT NULL,
    token       TEXT NOT NULL,
    is_default  BOOLEAN DEFAULT false,
    expires_at  DATE,
    created_at  TIMESTAMPTZ DEFAULT now(),

    FOREIGN KEY (user_id)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
);
인덱스
CREATE INDEX ix_payment_user
ON billing.user_payment_methods (user_id);

CREATE INDEX ix_payment_default
ON billing.user_payment_methods (user_id)
WHERE is_default = true;
6️⃣ auth.roles
CREATE TABLE auth.roles (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_system   BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ DEFAULT now()
);
7️⃣ auth.permissions
CREATE TABLE auth.permissions (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    code        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT now()
);
8️⃣ auth.user_roles (N:M)
CREATE TABLE auth.user_roles (
    user_id    UUID NOT NULL,
    role_id    UUID NOT NULL,
    assigned_at TIMESTAMPTZ DEFAULT now(),

    PRIMARY KEY (user_id, role_id),

    FOREIGN KEY (user_id)
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (role_id)
        REFERENCES auth.roles(id)
        ON DELETE CASCADE
);
CREATE INDEX ix_user_roles_role
ON auth.user_roles (role_id);
9️⃣ auth.role_permissions (N:M)
CREATE TABLE auth.role_permissions (
    role_id       UUID NOT NULL,
    permission_id UUID NOT NULL,

    PRIMARY KEY (role_id, permission_id),

    FOREIGN KEY (role_id)
        REFERENCES auth.roles(id)
        ON DELETE CASCADE,

    FOREIGN KEY (permission_id)
        REFERENCES auth.permissions(id)
        ON DELETE CASCADE
);
CREATE INDEX ix_role_permissions_permission
ON auth.role_permissions (permission_id);
🔥 권한 체크 핵심 쿼리
SELECT 1
FROM auth.user_roles ur
JOIN auth.role_permissions rp ON ur.role_id = rp.role_id
JOIN auth.permissions p ON rp.permission_id = p.id
WHERE ur.user_id = $1
AND p.code = 'BOARD_DELETE'
LIMIT 1;

 */