CREATE SCHEMA IF NOT EXISTS map;


CREATE EXTENSION IF NOT EXISTS postgis;


CREATE OR REPLACE FUNCTION generate_pnu(
    lawd_cd VARCHAR,
    jibun_text VARCHAR
)
RETURNS VARCHAR AS $$
DECLARE
    clean_jibun TEXT;
    is_mountain CHAR(1);
    bon TEXT;
    bu TEXT;
BEGIN
    IF jibun_text LIKE '산%' THEN
        is_mountain := '1';
        clean_jibun := regexp_replace(jibun_text, '^산\s*', '');
    ELSE
        is_mountain := '0';
        clean_jibun := jibun_text;
    END IF;

    bon := split_part(clean_jibun, '-', 1);
    bu := split_part(clean_jibun, '-', 2);

    IF bu = '' THEN
        bu := '0';
    END IF;

    RETURN lawd_cd
        || is_mountain
        || lpad(bon, 4, '0')
        || lpad(bu, 4, '0');
END;
$$ LANGUAGE plpgsql;



CREATE TABLE IF NOT EXISTS map.regions (
    code        VARCHAR(10), -- 10자리
    _sido        VARCHAR(2) NOT NULL,
    _sigungu     VARCHAR(3) NOT NULL,
    _umd         VARCHAR(3) NOT NULL,
    _ri          VARCHAR(2),
    _is_active   BOOLEAN DEFAULT TRUE NOT NULL,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (code)
);

CREATE INDEX IF NOT EXISTS idx_regions_name
ON map.regions (_sido, _sigungu, _umd);

COMMENT ON TABLE map.regions IS '법정동 테이블, 행안부 법정동 API를 통해 수집';

COMMENT ON COLUMN map.regions.code IS '법정동 테이블 PK';
COMMENT ON COLUMN map.regions._sido IS '시도';
COMMENT ON COLUMN map.regions._sigungu IS '시군구';
COMMENT ON COLUMN map.regions._umd IS '법정동';
COMMENT ON COLUMN map.regions._ri IS '리';
COMMENT ON COLUMN map.regions._is_active IS '활성 여부(soft delete), 1:예 0: 아니요';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS map.land (
    pnu             VARCHAR(19) NOT NULL,
    region_code     VARCHAR(10) NOT NULL,

    _jibun          VARCHAR(30) NOT NULL,
    
    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (pnu),

    FOREIGN KEY (region_code)
    REFERENCES map.regions(code)
    ON DELETE SET CASCADE
);

CREATE INDEX IF NOT EXISTS idx_land_region_code ON land (region_code);

COMMENT ON TABLE map.land IS '토지 테이블, 법정동 테이블과 지번주소와 함께 generate_pnu 함수를 통해 수집';

COMMENT ON COLUMN map.land.pnu IS '토지 테이블 PK';
COMMENT ON COLUMN map.land.region_code IS '법정동 테이블 FK';
COMMENT ON COLUMN map.land._jibun IS '지번주소';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS map.building_complexes (
    id      UUID DEFAULT uuidv7() NOT NULL,

    api_pk  VARCHAR(100) NOT NULL,
    pnu     VARCHAR(19) NOT NULL,

    _name VARCHAR(200),
    _address TEXT,

    _lot_area NUMERIC(15,2),
    _building_count INTEGER,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),
    UNIQUE(api_pk),

    FOREIGN KEY (pnu)
    REFERENCES map.land(pnu)
    ON DELETE SET CASCADE
);

CREATE INDEX IF NOT EXISTS idx_building_complexes_pnu
ON map.building_complexes(pnu);

CREATE INDEX IF NOT EXISTS idx_building_complexes_name
ON map.building_complexes(_name);

COMMENT ON TABLE map.building_complexes IS '총괄표제부 테이블, 국토교통부 건축물대장 API를 통해 수집, 하나의 토지에 여러 빌딩이 아닌이상 없음';

COMMENT ON COLUMN map.building_complexes.id IS '총괄표제부 테이블 PK';
COMMENT ON COLUMN map.building_complexes.api_pk IS '국토교통부 API 건축물 고유식별자';
COMMENT ON COLUMN map.building_complexes.pnu IS '토지 테이블 FK';
COMMENT ON COLUMN map.building_complexes._name IS '총괄표제부 건축물명';
COMMENT ON COLUMN map.building_complexes._address IS '총괄표제부 전체주소';
COMMENT ON COLUMN map.building_complexes._lot_area IS '총괄표제부 대지면적';
COMMENT ON COLUMN map.building_complexes._building_count IS '총괄표제부 내 건축물 수';

------------------------------------------------------------

CREATE TABLE map.buildings (
    id      UUID DEFAULT uuidv7() NOT NULL,

    api_pk VARCHAR(100) NOT NULL,
    parent_api_pk VARCHAR(100), 
    complex_id UUID NULL,
    pnu VARCHAR(19) NOT NULL,

    _main_purpose VARCHAR(200),
    _structure VARCHAR(200),

    _floor_count INTEGER,
    _underground_floor_count INTEGER,

    _total_area NUMERIC(15,2),

    _approval_date DATE,


    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),
    UNIQUE(api_pk),

    FOREIGN KEY (complex_id)
    REFERENCES map.building_complexes(id)
    ON DELETE SET NULL,

    FOREIGN KEY (pnu)
    REFERENCES map.land(pnu)
    ON DELETE SET CASCADE
);

--PNU 기반 조회
CREATE INDEX IF NOT EXISTS idx_buildings_pnu
ON map.buildings(pnu);

--complex 조회
CREATE INDEX IF NOT EXISTS idx_buildings_complex_id
ON map.buildings(complex_id);

--PNU + complex 복합 (대단지 최적화)
CREATE INDEX IF NOT EXISTS idx_buildings_pnu_complex
ON map.buildings(pnu, complex_id);

--approval_date (연식 분석)
CREATE INDEX IF NOT EXISTS idx_buildings_approval_date
ON map.buildings(_approval_date);

--main_purpose 필터
CREATE INDEX IF NOT EXISTS idx_buildings_main_purpose
ON map.buildings(_main_purpose);

COMMENT ON TABLE map.buildings IS '표제부 테이블, 국토교통부 건축물대장 API를 통해 수집';

COMMENT ON COLUMN map.buildings.id IS '표제부 테이블 PK';
COMMENT ON COLUMN map.buildings.api_pk IS '국토교통부 API 건축물 고유식별자';
COMMENT ON COLUMN map.buildings.parent_api_pk IS '국토교통부 API 건축물 상위 고유식별자, 총괄표제부에 해당하며 없을 수 있음';
COMMENT ON COLUMN map.buildings.complex_id IS '총괄표제부 테이블 FK, 총괄표제부에 해당하며 없을 수 있음';
COMMENT ON COLUMN map.buildings.pnu IS '토지 테이블 FK';
COMMENT ON COLUMN map.buildings._building_name IS '건축물명';
COMMENT ON COLUMN map.buildings._main_purpose IS '용도';
COMMENT ON COLUMN map.buildings._structure IS '건물 공법';
COMMENT ON COLUMN map.buildings._floor_count IS '지상 층수';
COMMENT ON COLUMN map.buildings._underground_floor_count IS '지하 층수';
COMMENT ON COLUMN map.buildings._total_area IS '대지 면적';
COMMENT ON COLUMN map.buildings._approval_date IS '사용승인일';
------------------------------------------------------------

CREATE TABLE map.building_units (
    id      UUID DEFAULT uuidv7() NOT NULL,

    api_pk VARCHAR(100) NOT NULL,
    parent_api_pk VARCHAR(100) NOT NULL, 
    building_id UUID NOT NULL,

    _unit_number VARCHAR(50),
    _floor INTEGER,

    _area_private NUMERIC(15,2),
    _area_supply NUMERIC(15,2),

    _usage VARCHAR(200),

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),
    UNIQUE(api_pk),

    FOREIGN KEY (building_id)
    REFERENCES map.buildings(id)
    ON DELETE CASCADE,
);

--building 하위 조회 (핵심)
CREATE INDEX IF NOT EXISTS idx_building_units_building_id
ON map.building_units(building_id);

--동 + 호수 조회 최적화
CREATE INDEX IF NOT EXISTS idx_building_units_building_unit
ON map.building_units(building_id, _unit_number);

--면적 기반 분석
CREATE INDEX IF NOT EXISTS idx_building_units_area_private
ON map.building_units(_area_private);


COMMENT ON TABLE map.building_units IS '전유부 테이블, 국토교통부 건축물대장 API를 통해 수집';

COMMENT ON COLUMN map.building_units.id IS '전유부 테이블 PK';
COMMENT ON COLUMN map.building_units.api_pk IS '국토교통부 API 건축물 고유식별자';
COMMENT ON COLUMN map.building_units.parent_api_pk IS '국토교통부 API 건축물 상위 고유식별자';
COMMENT ON COLUMN map.building_units._unit_number IS '동/호수';
COMMENT ON COLUMN map.building_units._floor IS '층수';
COMMENT ON COLUMN map.building_units._area_private IS '전용면적';
COMMENT ON COLUMN map.building_units._area_supply IS '공급면적';
COMMENT ON COLUMN map.building_units._usage IS '용도';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS map.realestate_transactions (
    id      UUID DEFAULT uuidv7() NOT NULL,

  
     -- 자산 FK (하나만 채워짐)
    building_id UUID,
    land_id UUID,

    _asset_type VARCHAR(50) NOT NULL,
    _trade_type VARCHAR(50) NOT NULL,

    _contract_date DATE NOT NULL,

    _price BIGINT,             
    _deposit BIGINT,           
    _monthly_rent BIGINT,      

    _area NUMERIC(10,2),

    _floor INTEGER,

    _approval_date DATE,

    _is_cancelled BOOLEAN DEFAULT false,

    LIKE core.base_entity INCLUDING COMMENTS,


    PRIMARY KEY (id),
        FOREIGN KEY (building_id)
    REFERENCES map.buildings(id)
    ON DELETE CASCADE,
        FOREIGN KEY (land_id)
    REFERENCES map.lands(id)
    ON DELETE CASCADE,
);
-- 대상 자산 조회
CREATE INDEX IF NOT EXISTS idx_realestate_transactions_asset
ON map.realestate_transactions(asset_type, asset_id);

-- 계약일 정렬 (시세 그래프용)
CREATE INDEX IF NOT EXISTS idx_realestate_transactions_contract_date
ON map.realestate_transactions(contract_date DESC);

COMMENT ON TABLE map.realestate_transactions IS '부동산 거래내역 테이블, 국토교통부 매매/전세/월세 API 로 수집';

COMMENT ON COLUMN map.realestate_transactions.id IS '부동산 거래내역 PK';
COMMENT ON COLUMN map.realestate_transactions.building_id IS '건축물 테이블 FK';
COMMENT ON COLUMN map.realestate_transactions.land_id IS '토지 테이블 FK';
COMMENT ON COLUMN map.realestate_transactions._asset_type IS '거래 대상, code.cores - REALESTATE_TRANSACTION_ASSET_TYPE';
COMMENT ON COLUMN map.realestate_transactions._trade_type IS '거래 구분, code.cores - REALESTATE_TRANSACTION_TRADE_TYPE';
COMMENT ON COLUMN map.realestate_transactions._contract_date IS '거래일';
COMMENT ON COLUMN map.realestate_transactions._price IS '매매가';
COMMENT ON COLUMN map.realestate_transactions._deposit IS '전/월세 보증금';
COMMENT ON COLUMN map.realestate_transactions._monthly_rent IS '월세';
COMMENT ON COLUMN map.realestate_transactions._area IS '면적';
COMMENT ON COLUMN map.realestate_transactions._floor IS '층';
COMMENT ON COLUMN map.realestate_transactions._approval_date IS '건축연도';
COMMENT ON COLUMN map.realestate_transactions._is_cancelled IS '신고취소 여부, 1: 예 0: 아니요';

