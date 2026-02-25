CREATE SCHEMA IF NOT EXISTS board;

CREATE TABLE IF NOT EXISTS board.boards (
    id                  UUID DEFAULT uuidv7() NOT NULL,

    alias               VARCHAR(50) NOT NULL,
    _name                VARCHAR(100) NOT NULL,
    _description         TEXT,

    _is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    _is_commentable      BOOLEAN NOT NULL DEFAULT TRUE,
    _is_secretable       BOOLEAN NOT NULL DEFAULT FALSE,
    _is_attachable       BOOLEAN NOT NULL DEFAULT FALSE,
    _max_attachments     INT NOT NULL DEFAULT 10,                             
    _max_attachment_size BIGINT,                          

    _is_reactable        BOOLEAN NOT NULL DEFAULT TRUE,   
    _allow_like          BOOLEAN NOT NULL DEFAULT TRUE,
    _allow_dislike       BOOLEAN NOT NULL DEFAULT FALSE,
    _allow_share         BOOLEAN NOT NULL DEFAULT FALSE,

    _sort_order          INT NOT NULL DEFAULT 0,

    LIKE core.base_entity INCLUDING COMMENTS,


    PRIMARY KEY (id),
    UNIQUE (alias),
);

CREATE INDEX IF NOT EXISTS ix_boards_active_sort
ON board.boards (_is_active, _sort_order, _created_at DESC);

COMMENT ON TABLE board.boards IS '게시판 테이블';
COMMENT ON COLUMN board.boards.id IS '게시판 테이블 PK';
COMMENT ON COLUMN board.boards.alias IS '별칭';
COMMENT ON COLUMN board.boards._name IS '이름';
COMMENT ON COLUMN board.boards._description IS '설명';
COMMENT ON COLUMN board.boards._is_active IS '활성 여부(soft delete), 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._is_commentable IS '댓글 가능여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._is_secretable IS '비밀글 가능여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._is_attachable IS '첨부파일 가능여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._max_attachments IS '최대 첨부 가능 파일수';
COMMENT ON COLUMN board.boards._max_attachment_size IS '최대 첨부 가능 bytes 용량';
COMMENT ON COLUMN board.boards._is_reactable IS '반응 가능여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._allow_like IS '좋아요 허용여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._allow_dislike IS '싫어요 허용여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._allow_share IS '공유 허용여부, 1:예 0: 아니요';
COMMENT ON COLUMN board.boards._sort_order IS '정렬';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS board.posts (
    id                  UUID DEFAULT uuidv7() NOT NULL,
    board_id            UUID NOT NULL,

    account_id          UUID,

    _title              VARCHAR(200) NOT NULL,
    _content            TEXT NOT NULL,

    -- 상태/정책
    _status             VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED', -- DRAFT|PUBLISHED|HIDDEN|DELETED
    _is_notice          BOOLEAN NOT NULL DEFAULT FALSE,
    _is_pinned          BOOLEAN NOT NULL DEFAULT FALSE,
    _pinned_at          TIMESTAMPTZ,

    _is_secret          BOOLEAN NOT NULL DEFAULT FALSE,

    -- 집계(캐시)
    _view_count         BIGINT NOT NULL DEFAULT 0,
    _comment_count      BIGINT NOT NULL DEFAULT 0,
    _like_count         BIGINT NOT NULL DEFAULT 0,
    _dislike_count      BIGINT NOT NULL DEFAULT 0,
    _attachment_count   INT NOT NULL DEFAULT 0,
    _share_count        INT NOT NULL DEFAULT 0,


    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),

    FOREIGN KEY (board_id)
    REFERENCES board.boards(id)
    ON DELETE CASCADE,

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE SET NULL
);

-- 조회 화면에서 제일 많이 타는 인덱스들
CREATE INDEX IF NOT EXISTS ix_posts_board_status_published
ON board.posts (board_id, _status, _published_at DESC);

CREATE INDEX IF NOT EXISTS ix_posts_board_notice_pin
ON board.posts (board_id, _is_notice DESC, _is_pinned DESC, _pinned_at DESC, _published_at DESC);

-- 작성자 글 목록
CREATE INDEX IF NOT EXISTS ix_posts_author
ON board.posts (account_id, _published_at DESC);

COMMENT ON TABLE board.posts IS '게시글 테이블';
COMMENT ON COLUMN board.posts.id IS '게시글 테이블 PK';
COMMENT ON COLUMN board.posts.board_id IS '게시판 테이블 FK';
COMMENT ON COLUMN board.posts.account_id IS '계정 테이블 FK, 탈퇴 시 null';
COMMENT ON COLUMN board.posts._title IS '제목';
COMMENT ON COLUMN board.posts._content IS '내용';
COMMENT ON COLUMN board.posts._status IS '게시글 상태, core.codes - BOARD_POST_STATUS';
COMMENT ON COLUMN board.posts._is_notice IS '공지글 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN board.posts._is_pinned IS '고정글 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN board.posts._pinned_at IS '고정일자';
COMMENT ON COLUMN board.posts._is_secret IS '비밀글 여부, 1: 예 0: 아니요';
COMMENT ON COLUMN board.posts._view_count IS '조회수';
COMMENT ON COLUMN board.posts._comment_count IS '댓글수';
COMMENT ON COLUMN board.posts._like_count IS '좋아요수';
COMMENT ON COLUMN board.posts._dislike_count IS '싫어요수';
COMMENT ON COLUMN board.posts._attachment_count IS '첨부파일수';
COMMENT ON COLUMN board.posts._share_count IS '공유수';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS board.comments (
    id                  UUID DEFAULT uuidv7() NOT NULL,

    post_id             UUID NOT NULL,

    parent_id           UUID,

    account_id           UUID,

    _depth               INT NOT NULL DEFAULT 0,

    _content             TEXT NOT NULL,

    _status              VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED', -- PUBLISHED|HIDDEN|DELETED

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),

    FOREIGN KEY (post_id)
    REFERENCES board.posts(id)
    ON DELETE CASCADE,

    FOREIGN KEY (parent_id)
    REFERENCES board.comments(id)
    ON DELETE CASCADE,

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE SET NULL
);

-- 댓글 목록: post_id + parent_id + created_at 조합이 가장 흔함
CREATE INDEX IF NOT EXISTS ix_comments_post_parent_created
ON board.comments (post_id, parent_id, _created_at);

-- 대댓글 트리 탐색(부모 기준)
CREATE INDEX IF NOT EXISTS ix_comments_parent
ON board.comments (parent_id);

-- 작성자 댓글 목록
CREATE INDEX IF NOT EXISTS ix_comments_author
ON board.comments (account_id, _created_at DESC);

COMMENT ON TABLE board.comments IS '댓글 테이블';
COMMENT ON COLUMN board.comments.id IS '댓글 테이블 PK';
COMMENT ON COLUMN board.comments.post_id IS '게시글 테이블 FK';
COMMENT ON COLUMN board.comments.parent_id IS '상위 댓글 ID FK';
COMMENT ON COLUMN board.comments.account_id IS '계정 테이블 FK, 탈퇴 시 null';
COMMENT ON COLUMN board.comments._depth IS '깊이, 0: 댓글 1이상: 대댓글';
COMMENT ON COLUMN board.comments._content IS '내용';
COMMENT ON COLUMN board.comments._status IS '댓글 상태, core.codes - BOARD_COMMENT_STATUS';

------------------------------------------------------------

CREATE TABLE IF NOT EXISTS board.attachments (
    id                  UUID DEFAULT uuidv7() NOT NULL,
    post_id             UUID NOT NULL,

    _file_name           VARCHAR(255) NOT NULL,
    _file_path           VARCHAR(500) NOT NULL,
    _file_size           BIGINT NOT NULL,
    _mime_type           VARCHAR(100),
    _checksum            VARCHAR(128),           

    _status              VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    LIKE core.base_entity INCLUDING COMMENTS,

    PRIMARY KEY (id),

    FOREIGN KEY (post_id)
    REFERENCES board.posts(id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_attachments_post
ON board.attachments (post_id, _created_at);

CREATE INDEX IF NOT EXISTS ix_attachments_status
ON board.attachments (status, _created_at DESC);

COMMENT ON TABLE board.attachments IS '첨부파일 테이블';
COMMENT ON COLUMN board.attachments.id IS '첨부파일 테이블 PK';
COMMENT ON COLUMN board.attachments.post_id IS '게시글 테이블 FK';
COMMENT ON COLUMN board.attachments._file_name IS '파일명';
COMMENT ON COLUMN board.attachments._file_path IS '파일경로, S3 key 또는 CDN path';
COMMENT ON COLUMN board.attachments._file_size IS '파일용량 bytes';
COMMENT ON COLUMN board.attachments._mime_type IS '파일 밈타입';
COMMENT ON COLUMN board.attachments._checksum IS 'sha256 체크썸';
COMMENT ON COLUMN board.attachments._status IS '댓글 상태, core.codes - BOARD_POST_ATTACHMENT_STATUS';


------------------------------------------------------------

CREATE TABLE IF NOT EXISTS board.post_reactions (
    post_id     UUID NOT NULL,
    account_id  UUID NOT NULL,

    _reaction   VARCHAR(50) NOT NULL, 

    _count      INT NOT NULL DEFAULT 0,

    PRIMARY KEY (post_id, account_id),

    FOREIGN KEY (post_id)
    REFERENCES board.posts(id)
    ON DELETE CASCADE,

    FOREIGN KEY (account_id)
    REFERENCES account.accounts(id)
    ON DELETE SET CASCADE

);

-- 특정 유저가 좋아요 누른 글 목록
CREATE INDEX IF NOT EXISTS ix_post_reactions_account
ON board.post_reactions (account_id, created_at DESC);

-- 집계/운영용
CREATE INDEX IF NOT EXISTS ix_post_reactions_post
ON board.post_reactions (post_id, reaction);


COMMENT ON TABLE board.post_reactions IS '게시글 리액션 테이블';
COMMENT ON COLUMN board.post_reactions.post IS '게시글 테이블 FK';
COMMENT ON COLUMN board.post_reactions.account_id IS '계정 테이블 FK';
COMMENT ON COLUMN board.post_reactions._reaction IS '리액션, core.codes - BOARD_POST_REACTION';
COMMENT ON COLUMN board.post_reactions._count IS '리액션 횟수';