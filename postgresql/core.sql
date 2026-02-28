CREATE SCHEMA IF NOT EXISTS core;


CREATE TABLE IF NOT EXISTS core.base_entity (
    _created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    _updated_at TIMESTAMPTZ,
    _deleted_at TIMESTAMPTZ,
    _created_user TEXT NOT NULL DEFAULT 'superman',
    _updated_user TEXT,
    _deleted_user TEXT
);

COMMENT ON COLUMN core.base_entity._created_at IS '생성일자';
COMMENT ON COLUMN core.base_entity._updated_at IS '수정일자';
COMMENT ON COLUMN core.base_entity._deleted_at IS '삭제일자';
COMMENT ON COLUMN core.base_entity._created_user IS '생성자';
COMMENT ON COLUMN core.base_entity._updated_user IS '수정자';
COMMENT ON COLUMN core.base_entity._deleted_user IS '삭제자';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS core.code_groups (
    group_code VARCHAR(50) NOT NULL,
    _is_active BOOLEAN NOT NULL DEFAULT true,
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (group_code)
);

COMMENT ON TABLE core.code_groups IS '코드그룹 테이블';

COMMENT ON COLUMN core.code_groups.group_code IS '코드그룹 테이블 PK';
COMMENT ON COLUMN core.code_groups._is_active IS '활성여부, 1: 예 0: 아니요';

INSERT INTO core.code_groups VALUES
('ACCOUNT_STATUS', true, now(), null, null, 'superman', null, null),
('OAUTH_PROVIDER', true, now(), null, null, 'superman', null, null),
('DEVICE_TYPE', true, now(), null, null, 'superman', null, null),
('PUSH_PROVIDER', true, now(), null, null, 'superman', null, null),
('ACCOUNT_TYPE', true, now(), null, null, 'superman', null, null),
('MENU_PLATFORM', true, now(), null, null, 'superman', null, null),
('CORP_APPLICATION_STATUS', true, now(), null, null, 'superman', null, null),
('ACCOUNT_GENDER', true, now(), null, null, 'superman', null, null),
('BOARD_POST_STATUS', true, now(), null, null, 'superman', null, null),
('BOARD_COMMENT_STATUS', true, now(), null, null, 'superman', null, null),
('BOARD_POST_ATTACHMENT_STATUS', true, now(), null, null, 'superman', null, null),
('BOARD_POST_REACTION', true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_TRADE_TYPE', true, now(), null, null, 'superman', null, null)
ON CONFLICT (group_code) DO NOTHING;
------------------------------------------------------------

CREATE TABLE IF NOT EXISTS core.codes (
    group_code VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    _sort_order INTEGER NOT NULL DEFAULT 0,
    _is_active BOOLEAN NOT NULL DEFAULT true,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (group_code,code),

    FOREIGN KEY (group_code)
        REFERENCES core.code_groups(group_code)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_codes_group
ON core.codes (group_code, _is_active);

COMMENT ON TABLE core.codes IS '코드 테이블';

COMMENT ON COLUMN core.codes.group_code IS '코드그룹 테이블 FK';
COMMENT ON COLUMN core.codes.code IS '코드 테이블 PK';
COMMENT ON COLUMN core.codes._sort_order IS '정렬순서';
COMMENT ON COLUMN core.codes._is_active IS '활성여부, 1: 예 0: 아니요';

INSERT INTO core.codes VALUES
('ACCOUNT_STATUS', 'ACTIVE', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_STATUS', 'INACTIVE', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_STATUS', 'PENDING', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_STATUS', 'SUSPENDED', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_STATUS', 'WITHDRAWN', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_STATUS', 'DELETED', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_STATUS', 'DORMANT', 0, true, now(), null, null, 'superman', null, null),
('OAUTH_PROVIDER', 'GOOGLE', 0, true, now(), null, null, 'superman', null, null),
('DEVICE_TYPE', 'WEB', 0, true, now(), null, null, 'superman', null, null),
('DEVICE_TYPE', 'ANDROID', 0, true, now(), null, null, 'superman', null, null),
('DEVICE_TYPE', 'IOS', 0, true, now(), null, null, 'superman', null, null),
('PUSH_PROVIDER', 'FCM', 0, true, now(), null, null, 'superman', null, null),
('PUSH_PROVIDER', 'APNS', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_TYPE', 'MEMBER', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_TYPE', 'CORP', 0, true, now(), null, null, 'superman', null, null),
('MENU_PLATFORM', 'WEB', 0, true, now(), null, null, 'superman', null, null),
('MENU_PLATFORM', 'ANDROID', 0, true, now(), null, null, 'superman', null, null),
('MENU_PLATFORM', 'IOS', 0, true, now(), null, null, 'superman', null, null),
('MENU_PLATFORM', 'FLUTTER', 0, true, now(), null, null, 'superman', null, null),
('MENU_PLATFORM', 'ADMIN', 0, true, now(), null, null, 'superman', null, null),
('CORP_APPLICATION_STATUS', 'PENDING', 0, true, now(), null, null, 'superman', null, null),
('CORP_APPLICATION_STATUS', 'APPROVED', 0, true, now(), null, null, 'superman', null, null),
('CORP_APPLICATION_STATUS', 'REJECTED', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_GENDER', 'MALE', 0, true, now(), null, null, 'superman', null, null),
('ACCOUNT_GENDER', 'FEMALE', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_STATUS', 'DRAFT', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_STATUS', 'PUBLISHED', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_STATUS', 'HIDDEN', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_STATUS', 'DELETED', 0, true, now(), null, null, 'superman', null, null),
('BOARD_COMMENT_STATUS', 'PUBLISHED', 0, true, now(), null, null, 'superman', null, null),
('BOARD_COMMENT_STATUS', 'HIDDEN', 0, true, now(), null, null, 'superman', null, null),
('BOARD_COMMENT_STATUS', 'DELETED', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_ATTACHMENT_STATUS', 'ACTIVE', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_ATTACHMENT_STATUS', 'DELETED', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_REACTION', 'LIKE', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_REACTION', 'DISLIKE', 0, true, now(), null, null, 'superman', null, null),
('BOARD_POST_REACTION', 'SHARE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'STANDARD_REGION', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'BUILDING_REGISTER', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'APARTMENT_SALE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'APARTMENT_RENT', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'OFFICETEL_SALE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'OFFICETEL_RENT', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'SH_SALE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'SH_RENT', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'RH_SALE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'RH_RENT', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'LAND_SALE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'LAND_RENT', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'BUILDING_SALE', 0, true, now(), null, null, 'superman', null, null),
('COLLECT_API_SOURCE', 'BUILDING_RENT', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', 'APARTMENT', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', 'OFFICETEL', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', 'SH', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', 'RH', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', 'LAND', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_ASSET_TYPE', 'BUILDING', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_TRADE_TYPE', 'SALE', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_TRADE_TYPE', 'JEONSE', 0, true, now(), null, null, 'superman', null, null),
('REALESTATE_TRANSACTION_TRADE_TYPE', 'RENT', 0, true, now(), null, null, 'superman', null, null)


ON CONFLICT (group_code, code) DO NOTHING;

/* 
ACTIVE      활성	    정상 이용 가능
INACTIVE    비활성	    로그인 가능하지만 기능 제한
PENDING     가입대기	이메일 인증/관리자 승인 대기
SUSPENDED   정지	    정책 위반 등으로 사용 불가
WITHDRAWN   탈퇴	    사용자 탈퇴 완료
DELETED     삭제	    물리 삭제 또는 완전 비활성
DORMANT     휴면	    장기 미접속 계정
 */

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS core.languages (
    lang_code VARCHAR(10),   -- ko, en, ja
    _name VARCHAR(50) NOT NULL,
    _is_default BOOLEAN NOT NULL DEFAULT false,
    _is_active BOOLEAN NOT NULL DEFAULT true,
    LIKE core.base_entity INCLUDING COMMENTS,
    PRIMARY KEY (lang_code)
);


COMMENT ON TABLE core.languages IS '언어 테이블';

COMMENT ON COLUMN core.languages.lang_code IS '언어 테이블 PK';
COMMENT ON COLUMN core.languages._name IS '언어명';
COMMENT ON COLUMN core.languages._is_default IS '기본여부, 1: 예 0: 아니요';
COMMENT ON COLUMN core.languages._is_active IS '활성여부, 1: 예 0: 아니요';


INSERT INTO core.languages VALUES
('ko', '한국어', true, true, now(), null, null, 'superman', null, null),
('en', 'English', false, true, now(), null, null, 'superman', null, null)
ON CONFLICT (lang_code) DO NOTHING;
------------------------------------------------------------

CREATE TABLE IF NOT EXISTS core.i18n (
    message_key VARCHAR(200) NOT NULL,
    lang_code VARCHAR(10) NOT NULL,

    message TEXT NOT NULL,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (message_key, lang_code),

    FOREIGN KEY (lang_code)
        REFERENCES core.languages(lang_code)
        ON DELETE CASCADE
);

COMMENT ON TABLE core.i18n IS '다국어 테이블';


COMMENT ON COLUMN core.i18n.message_key IS '다국어 테이블 PK';
COMMENT ON COLUMN core.i18n.lang_code IS '언어 테이블 FK';
COMMENT ON COLUMN core.i18n.message IS '메세지';

INSERT INTO core.i18n VALUES
('CODE_GROUP.ACCOUNT_STATUS.NAME', 'ko', '회원상태', now(), null, null, 'superman', null, null),
('CODE_GROUP.ACCOUNT_STATUS.DESCRIPTION', 'ko', '회원상태설명', now(), null, null, 'superman', null, null),

('CODE_GROUP.ACCOUNT_STATUS.NAME', 'en', 'User Status', now(), null, null, 'superman', null, null),
('CODE_GROUP.ACCOUNT_STATUS.DESCRIPTION', 'en', 'User Description', now(), null, null, 'superman', null, null),

('CODE.ACCOUNT_STATUS.ACTIVE', 'ko', '활성', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.ACTIVE', 'en', 'Active', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.INACTIVE', 'ko', '비활성', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.INACTIVE', 'en', 'InActive', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.PENDING', 'ko', '가입대기', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.PENDING', 'en', 'Pending', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.SUSPENDED', 'ko', '정지', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.SUSPENDED', 'en', 'Suspended', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.WITHDRAWN', 'ko', '탈퇴', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.WITHDRAWN', 'en', 'Withdrawn', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.DELETED', 'ko', '삭제', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.DELETED', 'en', 'Deleted', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.DORMANT', 'ko', '휴면', now(), null, null, 'superman', null, null),
('CODE.ACCOUNT_STATUS.DORMANT', 'en', 'Dormant', now(), null, null, 'superman', null, null),
('CODE.OAUTH_PROVIDER.GOOGLE', 'ko', '구글', now(), null, null, 'superman', null, null),
('CODE.OAUTH_PROVIDER.GOOGLE', 'en', 'Google', now(), null, null, 'superman', null, null)
ON CONFLICT (message_key,lang_code) DO NOTHING;



/* 
message_key 형식
{DOMAIN}.{CATEGORY}.{IDENTIFIER}
코드
CODE.ACCOUNT_STATUS.ACTIVE
CODE.OAUTH_PROVIDER.GOOGLE
메뉴
MENU.SIDEBAR.DASHBOARD
MENU.SIDEBAR.USERS
권한
PERMISSION.USER.CREATE
PERMISSION.USER.DELETE
에러
ERROR.AUTH.INVALID_PASSWORD
ERROR.AUTH.UNAUTHORIZED
일반 메시지
COMMON.BUTTON.SAVE
COMMON.BUTTON.CANCEL
 */

