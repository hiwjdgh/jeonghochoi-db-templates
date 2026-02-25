CREATE SCHEMA IF NOT EXISTS account;

CREATE TABLE IF NOT EXISTS account.accounts (
    id UUID DEFAULT uuidv7() NOT NULL,
    _type VARCHAR(50) NOT NULL, 
    _status VARCHAR(50) NOT NULL,
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS ix_account_created_at
ON account.accounts(_created_at DESC);

CREATE INDEX IF NOT EXISTS ix_accounts_status
ON account.accounts (_status);


COMMENT ON TABLE account.accounts IS '계정 테이블';

COMMENT ON COLUMN account.accounts.id IS '계정 테이블 PK';
COMMENT ON COLUMN account.accounts._type IS '계정 구분, core.codes - ACCOUNT_TYPE';
COMMENT ON COLUMN account.accounts._status IS '계정 상태, core.codes - ACCOUNT_STATUS';

------------------------------------------------------------
CREATE TABLE IF NOT EXISTS account.account_oauths (
    id UUID DEFAULT uuidv7() NOT NULL,
    account_id UUID NOT NULL,
    _provider VARCHAR(50) NOT NULL,
    _access_token TEXT NOT NULL,
    _refresh_token TEXT NOT NULL,
    _expired_at TIMESTAMPTZ NOT NULL,
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (id),

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE CASCADE
);

COMMENT ON TABLE account.account_oauths IS '계정 OAuth 테이블';

COMMENT ON COLUMN account.account_oauths.id IS '계정 OAuth 테이블 PK';
COMMENT ON COLUMN account.account_oauths.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN account.account_oauths._provider IS 'OAuth 제공처, core.codes - OAUTH_PROVIDER';
COMMENT ON COLUMN account.account_oauths._access_token IS '엑세스 토큰';
COMMENT ON COLUMN account.account_oauths._refresh_token IS '리프레시 토큰';
COMMENT ON COLUMN account.account_oauths._expired_at IS '만료일자';


------------------------------------------------------------

CREATE TABLE IF NOT EXISTS account.account_profiles (
    id UUID DEFAULT uuidv7() NOT NULL,
    account_id UUID NOT NULL,

    alias VARCHAR(100),

    _nickname     VARCHAR(100),
    _avatar_url   TEXT,
    _timezone   VARCHAR(50) DEFAULT 'Asia/Seoul',
    _language VARCHAR(20) DEFAULT 'ko',
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (id),
    UNIQUE (alias),

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE CASCADE
);


COMMENT ON TABLE account.account_profiles IS '계정 프로필 테이블';

COMMENT ON COLUMN account.account_profiles.id IS '계정 프로필 테이블 PK';
COMMENT ON COLUMN account.account_profiles.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN account.account_profiles.alias IS '별칭';
COMMENT ON COLUMN account.account_profiles._nickname IS '닉네임';
COMMENT ON COLUMN account.account_profiles._avatar_url IS '프로필 이미지 URL';
COMMENT ON COLUMN account.account_profiles._timezone IS '타임존';
COMMENT ON COLUMN account.account_profiles._language IS '언어';



------------------------------------------------------------

CREATE TABLE IF NOT EXISTS account.account_devices (
    id UUID DEFAULT uuidv7() NOT NULL,
    account_id UUID NOT NULL,

    _device_type         VARCHAR(50) NOT NULL, 
    _device_os_version   VARCHAR(50),
    _app_version         VARCHAR(50),

    _push_token          TEXT,
    _push_provider       VARCHAR(50),          

    _is_active           BOOLEAN NOT NULL DEFAULT true,
    _is_push_enabled     BOOLEAN NOT NULL DEFAULT true,

    _last_login_at       TIMESTAMPTZ,

    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (id),

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE CASCADE
);


COMMENT ON TABLE account.account_devices IS '계정 프로필 테이블';

COMMENT ON COLUMN account.account_devices.id IS '계정 프로필 테이블 PK';
COMMENT ON COLUMN account.account_devices.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN account.account_devices._device_type IS '기기 구분, core.codes - DEVICE_TYPE';
COMMENT ON COLUMN account.account_devices._device_os_version IS '기기 OS 버전';
COMMENT ON COLUMN account.account_devices._app_version IS '기기 앱 버전';
COMMENT ON COLUMN account.account_devices._push_token IS '푸시 토큰';
COMMENT ON COLUMN account.account_devices._push_provider IS '푸시 구분, core.codes - PUSH_PROVIDER';
COMMENT ON COLUMN account.account_devices._is_active IS '활성 디바이스 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN account.account_devices._is_push_enabled IS '푸시 활성 여부, 1:예 0: 아니요';
COMMENT ON COLUMN account.account_devices._last_login_at IS '마지막 로그인일자';


CREATE INDEX IF NOT EXISTS ix_account_devices_account
ON account.account_devices (account_id);

CREATE INDEX IF NOT EXISTS ix_account_devices_push
ON account.account_devices (_push_token)
WHERE _push_token IS NOT NULL;


------------------------------------------------------------

CREATE TABLE IF NOT EXISTS account.corporations (
    id UUID DEFAULT uuidv7(),
    application_id UUID NOT NULL,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),

    FOREIGN KEY (application_id)
    REFERENCES private.corporation_applications(id)
    ON DELETE RESTRICT
);

COMMENT ON TABLE account.corporations IS '승인된 법인 테이블';

COMMENT ON COLUMN account.corporations.id IS '승인된 법인 테이블 PK';
COMMENT ON COLUMN account.corporations.application_id IS '법인 가입신청 테이블 PK';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS account.corporation_members (
    account_id UUID NOT NULL,
    corporation_id UUID NOT NULL,

    PRIMARY KEY (account_id, corporation_id),

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE RESTRICT,

    FOREIGN KEY (corporation_id)
    REFERENCES account.corporations(id)
    ON DELETE RESTRICT
);

COMMENT ON TABLE account.corporation_members IS '승인된 법인직원 테이블';

COMMENT ON COLUMN account.corporation_members.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN account.corporation_members.corporation_id IS '법인 테이블 FK';
