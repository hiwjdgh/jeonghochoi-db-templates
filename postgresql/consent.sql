CREATE SCHEMA IF NOT EXISTS consent;


CREATE TABLE IF NOT EXISTS consent.consents (
    id                  UUID DEFAULT uuidv7() NOT NULL,

    alias               VARCHAR(50) NOT NULL,
    _title               VARCHAR(200) NOT NULL,
    _description         TEXT NOT NULL,
    _is_required         BOOLEAN NOT NULL DEFAULT FALSE,
    _is_active           BOOLEAN NOT NULL DEFAULT TRUE,

    _country_code        CHAR(2) NOT NULL,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),
    UNIQUE (alias)
);


COMMENT ON TABLE consent.consents IS '동의 항목 테이블';

COMMENT ON COLUMN consent.consents.id IS '동의 항목 테이블 PK';
COMMENT ON COLUMN consent.consents.alias IS '별칭';
COMMENT ON COLUMN consent.consents._title IS '제목';
COMMENT ON COLUMN consent.consents._description IS '설명';
COMMENT ON COLUMN consent.consents._is_required IS '필수 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN consent.consents._is_active IS '활성 여부(soft delete), 1: 예 0: 아니요';
COMMENT ON COLUMN consent.consents._country_code IS '국가코드';

INSERT INTO consent.consents
VALUES
(uuidv7(), 'TERM_OF_SERVICE', '서비스 이용약관동의', '서비스 이용약관동의', true, true, 'kr', now(), null, null, 'superman', null, null),
(uuidv7(), 'TERM_OF_MARKETING', '마케팅 수신동의', '마케팅 수신동의', false, true, 'kr', now(), null, null, 'superman', null, null),
(uuidv7(), 'TERM_OF_LOCATION', '위치정보 수집동의', '위치정보 수집동의', true, true, 'kr', now(), null, null, 'superman', null, null),
(uuidv7(), 'TERM_OF_PRIVATE', '개인정보 수집동의', '개인정보 수집동의', true, true, 'kr', now(), null, null, 'superman', null, null)
ON CONFLICT (alias) DO NOTHING;

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS consent.consent_documents (
    id                  UUID DEFAULT uuidv7() NOT NULL,
    consent_id          UUID NOT NULL,
    version             VARCHAR(20) NOT NULL,
    _title               VARCHAR(200) NOT NULL,
    _content             TEXT NOT NULL,           
    _effective_from      TIMESTAMPTZ NOT NULL,
    _effective_to        TIMESTAMPTZ,

    _is_active           BOOLEAN NOT NULL DEFAULT TRUE,

    LIKE core.base_entity INCLUDING COMMENTS,


    PRIMARY KEY (id),

    UNIQUE(consent_id, version),

    FOREIGN KEY (consent_id)
    REFERENCES consent.consents(id)
    ON DELETE CASCADE
);


COMMENT ON TABLE consent.consent_documents IS '동의 항목 내용 테이블';

COMMENT ON COLUMN consent.consent_documents.id IS '동의 항목 내용 테이블 PK';
COMMENT ON COLUMN consent.consent_documents.consent_id IS '동의 항목 테이블 FK';
COMMENT ON COLUMN consent.consent_documents.version IS '버전';
COMMENT ON COLUMN consent.consent_documents._title IS '제목';
COMMENT ON COLUMN consent.consent_documents._content IS '내용';
COMMENT ON COLUMN consent.consent_documents._effective_from IS '효력 시작일자';
COMMENT ON COLUMN consent.consent_documents._effective_to IS '효력 종료일자';
COMMENT ON COLUMN consent.consent_documents._is_active IS '활성 여부(soft delete), 1: 예 0: 아니요';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS consent.account_consents (
    account_id              UUID NOT NULL,
    consent_id              UUID NOT NULL,
    consent_document_id     UUID NOT NULL,

    _is_agreed               BOOLEAN NOT NULL,
    _agreed_at               TIMESTAMPTZ NOT NULL,

    PRIMARY KEY (account_id, consent_id, consent_document_id),


    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE RESTRICT,


    FOREIGN KEY (consent_id)
    REFERENCES consent.consents(id)
    ON DELETE RESTRICT,

    FOREIGN KEY (consent_document_id)
    REFERENCES consent.consent_documents(id)
    ON DELETE RESTRICT
);


COMMENT ON TABLE consent.account_consents IS '계정의 동의 테이블';

COMMENT ON COLUMN consent.account_consents.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN consent.account_consents.consent_id IS '동의 항목 테이블 FK';
COMMENT ON COLUMN consent.account_consents.consent_document_id IS '동의 항목 내용 테이블 FK';
COMMENT ON COLUMN consent.account_consents._is_agreed IS '동의 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN consent.account_consents._agreed_at IS '동의일자';