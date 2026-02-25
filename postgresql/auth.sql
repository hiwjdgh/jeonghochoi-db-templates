CREATE SCHEMA IF NOT EXISTS auth;


CREATE TABLE IF NOT EXISTS auth.roles (
    id UUID DEFAULT uuidv7() ,
    code VARCHAR(50) NOT NULL,
    _name VARCHAR(100) NOT NULL,
    _description TEXT,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY(id),
    UNIQUE(code)
);

COMMENT ON TABLE auth.roles IS '역할 테이블';

COMMENT ON COLUMN auth.roles.id IS '역할 테이블 PK';
COMMENT ON COLUMN auth.roles.code IS '역할 고유 코드';
COMMENT ON COLUMN auth.roles._name IS '역할명';
COMMENT ON COLUMN auth.roles._description IS '역할 설명';



INSERT INTO auth.roles VALUES
(uuidv7(), 'GUEST', '비회원', '비회원', now(), null, null, 'superman', null, null),
(uuidv7(), 'CORP_OWNER', '법인대표', '법인대표', now(), null, null, 'superman', null, null),
(uuidv7(), 'CORP_MANAGER', '법인관리자', '법인관리자', now(), null, null, 'superman', null, null),
(uuidv7(), 'CORP_STAFF', '법인직원', '법인직원', now(), null, null, 'superman', null, null),
(uuidv7(), 'ADMIN_SUPER', '최고관리자', '최고관리자', now(), null, null, 'superman', null, null),
(uuidv7(), 'ADMIN_CS_MANAGER', '부서관리자', '부서관리자', now(), null, null, 'superman', null, null),
(uuidv7(), 'ADMIN_CS_STAFF', '부서직원', '부서직원', now(), null, null, 'superman', null, null),
(uuidv7(), 'MEMBER_BASIC', '일반회원', '일반회원', now(), null, null, 'superman', null, null),
(uuidv7(), 'MEMBER_INTERNAL_TESTER', '내부직원테스트회원', '내부직원테스트회원', now(), null, null, 'superman', null, null),
(uuidv7(), 'MEMBER_EXTERNAL_TESTER', '외부테스트회원', '외부테스트회원', now(), null, null, 'superman', null, null)
ON CONFLICT (code) DO NOTHING;

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS auth.permissions (
    id UUID DEFAULT uuidv7(),
    code VARCHAR(100)  NOT NULL,
    _resource VARCHAR(100) NOT NULL,
    _action VARCHAR(50) NOT NULL,
    _description TEXT,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),
    UNIQUE (code)
);

CREATE INDEX IF NOT EXISTS ix_permissions_resource
ON auth.permissions(_resource);

COMMENT ON TABLE auth.permissions IS '권한 테이블';

COMMENT ON COLUMN auth.permissions.id IS '권한 테이블 PK';
COMMENT ON COLUMN auth.permissions.code IS '권한 고유 코드';
COMMENT ON COLUMN auth.permissions._resource IS '권한이 적용되는 대상 리소스';
COMMENT ON COLUMN auth.permissions._action IS '리소스에 대해 허용되는 행위';
COMMENT ON COLUMN auth.permissions._description IS '권한 설명';

INSERT INTO auth.permissions
VALUES
-- =====================
-- 공통 (개인)
-- =====================
(uuidv7(), 'PROFILE_READ', 'PROFILE', 'READ', '프로필 조회', now(), null, null, 'superman', null, null),
(uuidv7(), 'PROFILE_UPDATE', 'PROFILE', 'UPDATE', '프로필 수정', now(), null, null, 'superman', null, null),

(uuidv7(), 'CHARGE_READ', 'CHARGE', 'READ', '충전 이력 조회', now(), null, null, 'superman', null, null),
(uuidv7(), 'CHARGE_CREATE', 'CHARGE', 'CREATE', '충전 시작', now(), null, null, 'superman', null, null),

(uuidv7(), 'RESERVATION_CREATE', 'RESERVATION', 'CREATE', '예약 생성', now(), null, null, 'superman', null, null),
(uuidv7(), 'RESERVATION_CANCEL', 'RESERVATION', 'CANCEL', '예약 취소', now(), null, null, 'superman', null, null),

(uuidv7(), 'CARD_MANAGE', 'CARD', 'MANAGE', '결제 카드 관리', now(), null, null, 'superman', null, null),
-- =====================
-- 법인 전용
-- =====================
(uuidv7(), 'INVOICE_DOWNLOAD', 'INVOICE', 'DOWNLOAD', '세금계산서 다운로드', now(), null, null, 'superman', null, null),
(uuidv7(), 'CORP_MEMBER_MANAGE', 'CORP_MEMBER', 'MANAGE', '법인 직원 관리', now(), null, null, 'superman', null, null),
(uuidv7(), 'CORP_REPORT_READ', 'CORP_REPORT', 'READ', '법인 리포트 조회', now(), null, null, 'superman', null, null),

-- =====================
-- 관리자
-- =====================
(uuidv7(), 'ADMIN_USER_READ', 'ADMIN_USER', 'READ', '회원 조회', now(), null, null, 'superman', null, null),
(uuidv7(), 'ADMIN_USER_UPDATE', 'ADMIN_USER', 'UPDATE', '회원 수정', now(), null, null, 'superman', null, null),
(uuidv7(), 'ADMIN_USER_DELETE', 'ADMIN_USER', 'DELETE', '회원 삭제', now(), null, null, 'superman', null, null),

(uuidv7(), 'ADMIN_PERMISSION_MANAGE', 'ADMIN_PERMISSION', 'MANAGE', '권한 관리', now(), null, null, 'superman', null, null),
(uuidv7(), 'ADMIN_ORG_MANAGE', 'ADMIN_ORG', 'MANAGE', '법인 관리', now(), null, null, 'superman', null, null),

-- =====================
-- 테스트/확장
-- =====================
(uuidv7(), 'FEATURE_BETA_ACCESS', 'FEATURE', 'BETA', '베타 기능 접근', now(), null, null, 'superman', null, null)
ON CONFLICT (code) DO NOTHING;

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS auth.role_permissions (
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    PRIMARY KEY (role_id, permission_id),

    FOREIGN KEY (role_id)
    REFERENCES auth.roles(id)
    ON DELETE CASCADE,

    FOREIGN KEY (permission_id)
    REFERENCES auth.permissions(id)
    ON DELETE RESTRICT

);

CREATE INDEX IF NOT EXISTS ix_role_permissions_role
ON auth.role_permissions(role_id);

CREATE INDEX IF NOT EXISTS ix_role_permissions_permission
ON auth.role_permissions(permission_id);

COMMENT ON TABLE auth.role_permissions IS '역할과 권한 매핑 테이블';

COMMENT ON COLUMN auth.role_permissions.role_id IS '역할 테이블 FK';
COMMENT ON COLUMN auth.role_permissions.permission_id IS '권한 테이블 FK';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS auth.account_roles (
    account_id UUID NOT NULL,
    role_id UUID NOT NULL,
    organization_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',

    PRIMARY KEY (account_id, role_id, organization_id),

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE CASCADE,

    FOREIGN KEY (role_id)
    REFERENCES auth.roles(id)
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_account_roles_account
ON auth.account_roles(account_id);

CREATE INDEX IF NOT EXISTS ix_account_roles_org
ON auth.account_roles(organization_id);

CREATE INDEX IF NOT EXISTS ix_account_roles_role
ON auth.account_roles(role_id);

COMMENT ON TABLE auth.account_roles IS '계정의 역할 부여 테이블';

COMMENT ON COLUMN auth.account_roles.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN auth.account_roles.role_id IS '역할 테이블 FK';
COMMENT ON COLUMN auth.account_roles.organization_id IS '역할의 적용 조직 범위';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS auth.menus (
    id UUID DEFAULT uuidv7() ,
    parent_id UUID,
    code VARCHAR(100)  NOT NULL,
    _name VARCHAR(100) NOT NULL,
    _path VARCHAR(200),
    _platform VARCHAR(20), -- ADMIN / APP / WEB

    _sort_order INT DEFAULT 0,
    _is_visible BOOLEAN DEFAULT TRUE,

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),
    UNIQUE (code),

    FOREIGN KEY (parent_id)
    REFERENCES auth.menus(id)
    ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS ix_menus_parent
ON auth.menus(parent_id);

CREATE INDEX IF NOT EXISTS ix_menus_platform
ON auth.menus(_platform);

COMMENT ON TABLE auth.menus IS '시스템 내 메뉴 테이블';

COMMENT ON COLUMN auth.menus.id IS '시스템 내 메뉴 테이블 PK';
COMMENT ON COLUMN auth.menus.parent_id IS '상위 메뉴 ID FK';
COMMENT ON COLUMN auth.menus.code IS '메뉴 고유 코드';
COMMENT ON COLUMN auth.menus._name IS '표기될 메뉴명';
COMMENT ON COLUMN auth.menus._path IS '메뉴 라우팅 주소';
COMMENT ON COLUMN auth.menus._platform IS '메뉴가 적용되는 플랫폼, core.codes - MENU_PLATFORM';
COMMENT ON COLUMN auth.menus._sort_order IS '동일 레벨 메뉴 내 정렬 순서';
COMMENT ON COLUMN auth.menus._is_visible IS '메뉴 표기 여부, 1: 예 0: 아니요';


INSERT INTO auth.menus
VALUES
-- =====================
-- APP(ANDROID, IOS, FLUTTER)
-- =====================
(uuidv7(), null, 'APP_HOME', '홈', '/home', 'APP', 1, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'APP_CHARGE', '충전', '/charge', 'APP', 2, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'APP_RESERVATION', '예약', '/reservation', 'APP', 3, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'APP_CARD', '결제수단', '/card', 'APP', 4, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'APP_PROFILE', '내 정보', '/profile', 'APP', 5, true, now(), null, null, 'superman', null, null),

-- =====================
-- WEB
-- =====================
(uuidv7(), null, 'WEB_DASHBOARD', '대시보드', '/dashboard', 'WEB', 1, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'WEB_CHARGE_HISTORY', '충전 내역', '/charges', 'WEB', 2, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'WEB_INVOICE', '세금계산서', '/invoice', 'WEB', 3, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'WEB_CORP_MEMBERS', '직원 관리', '/members', 'WEB', 4, true, now(), null, null, 'superman', null, null),

-- =====================
-- ADMIN
-- =====================
(uuidv7(), null, 'ADMIN_DASHBOARD', '관리자 홈', '/admin', 'ADMIN', 1, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'ADMIN_USERS', '회원 관리', '/admin/users', 'ADMIN', 2, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'ADMIN_ORGS', '법인 관리', '/admin/orgs', 'ADMIN', 3, true, now(), null, null, 'superman', null, null),
(uuidv7(), null, 'ADMIN_ROLES', '권한 관리', '/admin/roles', 'ADMIN', 4, true, now(), null, null, 'superman', null, null)
ON CONFLICT (code) DO NOTHING;

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS auth.menu_permissions (
    menu_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    PRIMARY KEY (menu_id, permission_id),

    FOREIGN KEY (menu_id)
    REFERENCES auth.menus(id)
    ON DELETE CASCADE,
    
    FOREIGN KEY (permission_id)
    REFERENCES auth.permissions(id)
    ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_menu_permissions_menu
ON auth.menu_permissions(menu_id);

CREATE INDEX IF NOT EXISTS ix_menu_permissions_permission
ON auth.menu_permissions(permission_id);

COMMENT ON TABLE auth.menu_permissions IS '사용자 권한(Permission)에 따라 메뉴 노출을 제어하기 위한 매핑 테이블. 하나의 메뉴는 여러 권한을 요구할 수 있다.';

COMMENT ON COLUMN auth.menu_permissions.menu_id IS '메뉴 테이블 FK';
COMMENT ON COLUMN auth.menu_permissions.permission_id IS '권한 테이블 FK';
