CREATE SCHEMA IF NOT EXISTS private;


CREATE TABLE IF NOT EXISTS private.corporation_applications (
    id UUID DEFAULT uuidv7() NOT NULL,

    _business_name          VARCHAR(200) NOT NULL,
    _business_number        VARCHAR(50) NOT NULL,
    _representative_name    VARCHAR(100) NOT NULL,
    _contact_email          VARCHAR(200) NOT NULL,
    _contact_phone          VARCHAR(50),
    _contact_tel            VARCHAR(50),

    _status                 VARCHAR(50) NOT NULL DEFAULT 'PENDING',

    _reviewed_by            UUID,
    _reviewed_at            TIMESTAMPTZ,
    _reject_reason          TEXT,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id)
);

COMMENT ON TABLE private.corporation_applications IS '법인 가입신청 테이블';

COMMENT ON COLUMN private.corporation_applications.id IS '법인 가입신청 테이블 PK';
COMMENT ON COLUMN private.corporation_applications._business_name IS '법인명';
COMMENT ON COLUMN private.corporation_applications._business_number IS '법인 사업자번호';
COMMENT ON COLUMN private.corporation_applications._representative_name IS '법인 대표자명';
COMMENT ON COLUMN private.corporation_applications._contact_email IS '법인 연락 이메일';
COMMENT ON COLUMN private.corporation_applications._contact_phone IS '법인 연락 휴대폰번호';
COMMENT ON COLUMN private.corporation_applications._contact_tel IS '법인 연락 전화번호';
COMMENT ON COLUMN private.corporation_applications._status IS '법인 신청 상태, core.codes - CORP_APPLICATION_STATUS';
COMMENT ON COLUMN private.corporation_applications._reviewed_by IS '리뷰자';
COMMENT ON COLUMN private.corporation_applications._reviewed_at IS '리뷰일자';
COMMENT ON COLUMN private.corporation_applications._reject_reason IS '거절사유';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS private.account_privates (
    id                  UUID DEFAULT uuidv7() NOT NULL,
    account_id          UUID NOT NULL,
    _first_name         VARCHAR(100) NOT NULL,
    _middle_name        VARCHAR(100),
    _last_name          VARCHAR(100) NOT NULL,
    _email              VARCHAR(200),
    _phone              VARCHAR(50),
    _tel                VARCHAR(50),
    _gender             VARCHAR(50),
    _business_number    VARCHAR(50),
    _birth_date         DATE,
    _cert_di            TEXT,
    _cert_ci            TEXT,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),

    FOREIGN KEY (account_id)
        REFERENCES account.accounts(id)
        ON DELETE CASCADE
);

COMMENT ON TABLE private.account_privates IS '계정 개인정보 테이블';

COMMENT ON COLUMN private.account_privates.id IS '계정 개인정보 테이블 PK';
COMMENT ON COLUMN private.account_privates.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN private.account_privates._first_name IS '이름';
COMMENT ON COLUMN private.account_privates._middle_name IS '중간 이름';
COMMENT ON COLUMN private.account_privates._last_name IS '성';
COMMENT ON COLUMN private.account_privates._email IS '이메일';
COMMENT ON COLUMN private.account_privates._phone IS '휴대폰번호';
COMMENT ON COLUMN private.account_privates._tel IS '전화번호';
COMMENT ON COLUMN private.account_privates._gender IS '성별, core.codes - ACCOUNT_GENDER';
COMMENT ON COLUMN private.account_privates._business_number IS '사업자번호';
COMMENT ON COLUMN private.account_privates._birth_date IS '생년월일';
COMMENT ON COLUMN private.account_privates._cert_di IS 'DI 해시';
COMMENT ON COLUMN private.account_privates._cert_ci IS 'CI 해시';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS private.account_addresses (
    id                  UUID DEFAULT uuidv7() NOT NULL,
    account_id          UUID NOT NULL,

    alias              VARCHAR(50) NOT NULL,
    _recipient_name     VARCHAR(100) NOT NULL, 
    _recipient_phone    VARCHAR(50)  NOT NULL,

    _country_code       VARCHAR(2)   NOT NULL DEFAULT 'KR',
    _state              VARCHAR(120) NOT NULL,
    _city               VARCHAR(120) NOT NULL,
    _postal_code        VARCHAR(20)  NOT NULL,
    _address1           VARCHAR(255) NOT NULL, 
    _address2           VARCHAR(255) NOT NULL,          
    _address3           VARCHAR(255),          

    _is_default         BOOLEAN      NOT NULL DEFAULT FALSE,

    _lat                NUMERIC(10,7),
    _lng                NUMERIC(10,7),

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),

    UNIQUE(alias),

    FOREIGN KEY (account_id)
        REFERENCES account.accounts(id)
        ON DELETE CASCADE
);

COMMENT ON TABLE private.account_addresses IS '계정 주소 테이블';

COMMENT ON COLUMN private.account_addresses.id IS '계정 주소 테이블 PK';
COMMENT ON COLUMN private.account_addresses.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN private.account_addresses.alias IS '별칭';
COMMENT ON COLUMN private.account_addresses._recipient_name IS '수령인명';
COMMENT ON COLUMN private.account_addresses._recipient_phone IS '수령인 휴대폰번호';
COMMENT ON COLUMN private.account_addresses._country_code IS '국가코드';
COMMENT ON COLUMN private.account_addresses._state IS '주, 시/도';
COMMENT ON COLUMN private.account_addresses._city IS '도시, 시/군/구';
COMMENT ON COLUMN private.account_addresses._postal_code IS '우편번호';
COMMENT ON COLUMN private.account_addresses._address1 IS '기본주소';
COMMENT ON COLUMN private.account_addresses._address2 IS '상세주소';
COMMENT ON COLUMN private.account_addresses._address3 IS '참고항목/건물명';
COMMENT ON COLUMN private.account_addresses._is_default IS '기본 주소 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN private.account_addresses._lat IS '이름';
COMMENT ON COLUMN private.account_addresses._lng IS '이름';
