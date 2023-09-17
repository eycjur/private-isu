USE isuconp;
ALTER TABLE comments ADD INDEX idx_post_id_created_at(post_id, created_at);
ALTER TABLE posts ADD INDEX idx_created_at(created_at);
