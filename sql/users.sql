CREATE TABLE IF NOT EXISTS `users`
(
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    email                  VARCHAR(255) NOT NULL,
    password               VARCHAR(255) NOT NULL,
    created                TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    last_online            TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    mfa_secret             VARCHAR(255) DEFAULT NULL,
    password_reset_request BOOLEAN      DEFAULT FALSE,
    INDEX (email) -- Index the email to make it fast to query for users by email
)