CREATE SCHEMA IF NOT EXISTS collect;


CREATE TABLE IF NOT EXISTS collect.raw_successes (
    id            BIGSERIAL,

    source        VARCHAR(50) NOT NULL,
    source_pk     VARCHAR(64) NOT NULL,

    _payload       JSONB NOT NULL,            

    _ingested_at   DATE NOT NULL DEFAULT CURRENT_DATE,
    _created_at    TIMESTAMP NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    UNIQUE (source, source_pk)
);

-- 삭제 조건 최적화용
CREATE INDEX IF NOT EXISTS idx_raw_successes_ingested_at
ON collect.raw_successes (_ingested_at);

-- 조회/재처리 대비
CREATE INDEX IF NOT EXISTS idx_raw_successes_source
ON collect.raw_successes (source);


-- 삭제 전략(6개월 유지)
DELETE FROM collect.raw_successes
WHERE _ingested_at < CURRENT_DATE - INTERVAL '6 months';


COMMENT ON TABLE collect.raw_successes IS '수집 원천 마이그레이션 성공 테이블';

COMMENT ON COLUMN collect.raw_successes.id IS '수집 원천 마이그레이션 성공 테이블 PK';
COMMENT ON COLUMN collect.raw_successes.source IS '호출 타입, core.codes - COLLECT_API_SOURCE';
COMMENT ON COLUMN collect.raw_successes.source_pk IS '호출 해시값, 모든 컬럼 | 이후 md5';
COMMENT ON COLUMN collect.raw_successes._payload IS '원천 데이터';
COMMENT ON COLUMN collect.raw_successes._ingested_at IS '수집일자';
COMMENT ON COLUMN collect.raw_successes._created_at IS '생성일자';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS collect.raw_failures (
    id            BIGSERIAL,

    source        VARCHAR(50) NOT NULL,
    source_pk     VARCHAR(64) NOT NULL,

    _payload       JSONB NOT NULL,            
    _error_message TEXT NOT NULL,

    _ingested_at   DATE NOT NULL DEFAULT CURRENT_DATE,
    _created_at    TIMESTAMP NOT NULL DEFAULT now(),

    PRIMARY KEY (id),
    UNIQUE (source, source_pk)
);

-- 최근 실패 확인용
CREATE INDEX IF NOT EXISTS idx_raw_failures_ingested_at
ON collect.raw_failures (_ingested_at);

-- 조회/재처리 대비, 반복 실패 확인용
CREATE INDEX IF NOT EXISTS idx_raw_failures_source
ON collect.raw_failures (source);



COMMENT ON TABLE collect.raw_failures IS '수집 원천 마이그레이션 실패 테이블';

COMMENT ON COLUMN collect.raw_failures.id IS '수집 원천 마이그레이션 실패 테이블 PK';
COMMENT ON COLUMN collect.raw_failures.source IS '호출 타입, core.codes - COLLECT_API_SOURCE';
COMMENT ON COLUMN collect.raw_failures.source_pk IS '호출 해시값, 모든 컬럼 | 이후 md5';
COMMENT ON COLUMN collect.raw_failures._payload IS '원천 데이터';
COMMENT ON COLUMN collect.raw_failures._error_message IS '실패사유';
COMMENT ON COLUMN collect.raw_failures._ingested_at IS '수집일자';
COMMENT ON COLUMN collect.raw_failures._created_at IS '생성일자';

