USE isuconp;

ALTER TABLE comments ADD INDEX idx_post_id_created_at(post_id, created_at);
ALTER TABLE comments ADD INDEX idx_user_id(user_id);
ALTER TABLE posts ADD INDEX idex_created_at(created_at);