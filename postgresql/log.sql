CREATE SCHEMA IF NOT EXISTS log;


CREATE TABLE IF NOT EXISTS log.account_consent_logs (
    id                      UUID DEFAULT uuidv7() NOT NULL,
    account_id              UUID NOT NULL,
    consent_id              UUID NOT NULL,
    consent_document_id     UUID NOT NULL,
    _is_agreed               BOOLEAN NOT NULL,
    _agreed_at               TIMESTAMPTZ NOT NULL,


    PRIMARY KEY (id),

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE NO ACTION,


    FOREIGN KEY (consent_id)
    REFERENCES consent.consents(id)
    ON DELETE NO ACTION,

    FOREIGN KEY (consent_document_id)
    REFERENCES consent.consent_documents(id)
    ON DELETE NO ACTION
);


COMMENT ON TABLE log.account_consent_logs IS '계정 동의 이력 테이블';

COMMENT ON COLUMN log.account_consent_logs.id IS '계정 동의 이력 테이블 PK';
COMMENT ON COLUMN log.account_consent_logs.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN log.account_consent_logs.consent_id IS '동의 항목 테이블 FK';
COMMENT ON COLUMN log.account_consent_logs.consent_document_id IS '동의 항목 내용 테이블 FK';
COMMENT ON COLUMN log.account_consent_logs._is_agreed IS '동의 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN log.account_consent_logs._agreed_at IS '동의일자';

------------------------------------------------------------
