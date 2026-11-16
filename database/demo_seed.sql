-- =====================================================================
-- Online Voting System: clean seed database
--
-- Run as the MySQL root user. It DROPS and recreates every table in
-- `online_voting_system`, so any existing data in that database is lost.
--
--   users:              1 admin + 10 fictional demo students + 2 fictional faculty
--   posts:              7 student-council posts
--   permissions:        11, role_permissions: 15 (same as DataInitializer)
--   all other tables:   empty, filled by using the app
--   ballots:            not created here; the backend creates it on startup
--
-- Passwords: everyone (admin, students, faculty) = 12345678
-- Admin login: admin@manit.ac.in
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `online_voting_system`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `online_voting_system`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `ballots`;
DROP TABLE IF EXISTS `candidates`;
DROP TABLE IF EXISTS `election_officer_assignments`;
DROP TABLE IF EXISTS `elections`;
DROP TABLE IF EXISTS `eligibility_criteria`;
DROP TABLE IF EXISTS `nominations`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `permissions`;
DROP TABLE IF EXISTS `posts`;
DROP TABLE IF EXISTS `result_vote_counts`;
DROP TABLE IF EXISTS `results`;
DROP TABLE IF EXISTS `role_permissions`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `vote_participation`;
DROP TABLE IF EXISTS `voting_challenges`;

-- ------------------------------------------------------------ tables
CREATE TABLE `audit_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `action` varchar(50) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `timestamp` datetime(6) NOT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKjs4iimve3y0xssbtve5ysyef0` (`user_id`),
  CONSTRAINT `FKjs4iimve3y0xssbtve5ysyef0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `candidates` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `approved_at` datetime(6) NOT NULL,
  `election_id` bigint NOT NULL,
  `nomination_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKn1awf3kaerbp88aoqtqc30smv` (`user_id`,`election_id`),
  UNIQUE KEY `UKmeq4kyr98xrig78bk4e8fr1q6` (`nomination_id`),
  KEY `FKmdu3yssghrl36wth97l9b9a9d` (`election_id`),
  CONSTRAINT `FK1gq68a7jhvcayfmif1mvrubjm` FOREIGN KEY (`nomination_id`) REFERENCES `nominations` (`id`),
  CONSTRAINT `FKmdu3yssghrl36wth97l9b9a9d` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`),
  CONSTRAINT `FKme4fkelukmx2s63tlcrft6hio` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `election_officer_assignments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assigned_at` datetime(6) NOT NULL,
  `status` enum('ACTIVE','ENDED') NOT NULL,
  `assigned_by` bigint NOT NULL,
  `election_id` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKm23034pbtjr49n5no2ewpt2sq` (`user_id`,`election_id`),
  KEY `FKtggqm65lm4qi3oshs0y14pahs` (`assigned_by`),
  KEY `FKiqhrn1j3dfsnlfl7dbx07u10q` (`election_id`),
  CONSTRAINT `FKiqhrn1j3dfsnlfl7dbx07u10q` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`),
  CONSTRAINT `FKnok457pk6wq8p79ntlxb4uag7` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKtggqm65lm4qi3oshs0y14pahs` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `elections` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `department` varchar(255) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `end_date` datetime(6) NOT NULL,
  `start_date` datetime(6) NOT NULL,
  `status` enum('COMPLETED','ONGOING','UPCOMING') NOT NULL,
  `title` varchar(255) NOT NULL,
  `created_by` bigint NOT NULL,
  `post_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKncm1jn0m42hvnikns41yprhfn` (`created_by`),
  KEY `FKfdmqon0754w905pjg81hbh76k` (`post_id`),
  CONSTRAINT `FKfdmqon0754w905pjg81hbh76k` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `FKncm1jn0m42hvnikns41yprhfn` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `eligibility_criteria` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `election_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKoxt0gbxkwdxvxt2f7fxbf8j5i` (`election_id`),
  CONSTRAINT `FKddo3te4icl2u6n0abb4nb3pw1` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `nominations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `position` varchar(255) NOT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `status` enum('APPROVED','PENDING','REJECTED') NOT NULL,
  `submitted_at` datetime(6) NOT NULL,
  `election_id` bigint NOT NULL,
  `reviewed_by` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6cbw5r3yqrb92lof7l8svoi5y` (`user_id`,`election_id`),
  KEY `FKdqb1nd3ca3ghrd8w3o4eiwoew` (`election_id`),
  KEY `FKgyllibp5istpcj1ttyyyf4qda` (`reviewed_by`),
  CONSTRAINT `FKdqb1nd3ca3ghrd8w3o4eiwoew` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`),
  CONSTRAINT `FKgyllibp5istpcj1ttyyyf4qda` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `FKq5fxs4dlwmelyg0y2oornceo` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `notifications` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `is_read` bit(1) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `type` enum('NOMINATION_APPROVED','NOMINATION_REJECTED','EO_ASSIGNED') NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK9y21adhxn0ayjhfocscqox7bh` (`user_id`),
  CONSTRAINT `FK9y21adhxn0ayjhfocscqox7bh` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKpnvtwliis6p05pn6i3ndjrqt2` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `posts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(1000) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKjjhk5q12091gpef0xu20n6xfv` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `result_vote_counts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `vote_count` int NOT NULL,
  `candidate_id` bigint NOT NULL,
  `result_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKohibtdpuyjp66irso8kgw2tio` (`result_id`,`candidate_id`),
  KEY `FKbfqxtk2m1pft1abuj2rnhdd8r` (`candidate_id`),
  CONSTRAINT `FKbfqxtk2m1pft1abuj2rnhdd8r` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`),
  CONSTRAINT `FKoto9jkc00629g9uwnf7dl9iaj` FOREIGN KEY (`result_id`) REFERENCES `results` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `results` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `released_at` datetime(6) NOT NULL,
  `election_id` bigint NOT NULL,
  `released_by` bigint NOT NULL,
  `winner_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK3mvrow6qbuggfw4v10ivgp1ph` (`election_id`),
  KEY `FK4e3fafuqkhl56lr8hjghkqfvi` (`released_by`),
  KEY `FKjppbtiexiohkvgjxaivadqehh` (`winner_id`),
  CONSTRAINT `FK4e3fafuqkhl56lr8hjghkqfvi` FOREIGN KEY (`released_by`) REFERENCES `users` (`id`),
  CONSTRAINT `FKc4u2w8wi8slh0k23fmeuoy3r6` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`),
  CONSTRAINT `FKjppbtiexiohkvgjxaivadqehh` FOREIGN KEY (`winner_id`) REFERENCES `candidates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `role_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role` enum('ADMIN','ELECTION_OFFICER','VOTER') NOT NULL,
  `permission_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKriljgn66b857jm4uffdqtcsmy` (`role`,`permission_id`),
  KEY `FKegdk29eiy7mdtefy5c7eirr6e` (`permission_id`),
  CONSTRAINT `FKegdk29eiy7mdtefy5c7eirr6e` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course` varchar(255) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `department` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('ADMIN','ELECTION_OFFICER','VOTER') NOT NULL,
  `student_id` varchar(255) NOT NULL,
  `year` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`),
  UNIQUE KEY `UKqh3otyipv2k9hqte4a1abcyhq` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `vote_participation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `voted_at` datetime(6) NOT NULL,
  `election_id` bigint NOT NULL,
  `voter_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKdek4dtw63023yxpa1rygoajye` (`voter_id`,`election_id`),
  KEY `FKdl96roq5vcoq7lnm8bq9at89m` (`election_id`),
  CONSTRAINT `FKbgdkjkd1whcvj1db48kcm3xwb` FOREIGN KEY (`voter_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKdl96roq5vcoq7lnm8bq9at89m` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `voting_challenges` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `attempts` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `otp_hash` varchar(255) NOT NULL,
  `used` bit(1) NOT NULL,
  `verified` bit(1) NOT NULL,
  `election_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKi42eb7i5ycovo7i6xbdsg1qe2` (`election_id`),
  KEY `FKb8gia9fdhesxohxm5tx96uqvm` (`user_id`),
  CONSTRAINT `FKb8gia9fdhesxohxm5tx96uqvm` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKi42eb7i5ycovo7i6xbdsg1qe2` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------ permissions
INSERT INTO `permissions` (`id`, `description`, `name`) VALUES
  (1, 'View available elections', 'VIEW_ELECTION'),
  (2, 'Cast a vote in an election', 'CAST_VOTE'),
  (3, 'View election results', 'VIEW_RESULT'),
  (4, 'Submit a nomination', 'SUBMIT_NOMINATION'),
  (5, 'Create an election', 'CREATE_ELECTION'),
  (6, 'View election nominations', 'VIEW_NOMINATIONS'),
  (7, 'Approve a nomination', 'APPROVE_NOMINATION'),
  (8, 'Reject a nomination', 'REJECT_NOMINATION'),
  (9, 'Assign election officers', 'ASSIGN_ELECTION_OFFICER'),
  (10, 'View audit logs', 'VIEW_AUDIT_LOG'),
  (11, 'View registered users', 'VIEW_USERS');

INSERT INTO `role_permissions` (`id`, `role`, `permission_id`) VALUES
  (1, 'VOTER', 1),
  (2, 'VOTER', 2),
  (3, 'VOTER', 3),
  (4, 'VOTER', 4),
  (5, 'ELECTION_OFFICER', 1),
  (6, 'ELECTION_OFFICER', 2),
  (7, 'ELECTION_OFFICER', 3),
  (8, 'ELECTION_OFFICER', 4),
  (9, 'ELECTION_OFFICER', 5),
  (10, 'ELECTION_OFFICER', 6),
  (11, 'ELECTION_OFFICER', 7),
  (12, 'ELECTION_OFFICER', 8),
  (13, 'ADMIN', 9),
  (14, 'ADMIN', 10),
  (15, 'ADMIN', 11);

-- ------------------------------------------------------------ posts
INSERT INTO `posts` (`id`, `description`, `name`) VALUES
  (1, 'Head of the student council and primary representative of the student body', 'President'),
  (2, 'Assists the president and steps in when the president is unavailable', 'Vice President'),
  (3, 'Manages official records communications and administrative duties', 'General Secretary'),
  (4, 'Oversees student council funds budgets and financial reporting', 'Treasurer'),
  (5, 'Organizes and oversees university sports events and athletic programs', 'Sports Secretary'),
  (6, 'Coordinates cultural events festivals and student activities', 'Cultural Secretary'),
  (7, 'Acts as a liaison between students and faculty regarding academic matters', 'Academic Representative');

-- ------------------------------------------------------------ users
INSERT INTO `users` (`id`, `student_id`, `first_name`, `last_name`, `email`, `password`, `department`, `course`, `year`, `role`, `created_at`) VALUES
  (1, 'ADMIN001', 'System', 'Admin', 'admin@manit.ac.in', '$2a$10$JWsSJEJwZuf0/kZ9ShOjw.IzD3EdxDL840SZpOYxOKGsjkmFIsM3W', 'Administration', 'Administration', 1, 'ADMIN', NOW(6)),
  (2, '25204039901', 'Aarav', 'Sharma', '25204039901@stu.manit.ac.in', '$2a$10$rDv51yr.nA6jNeX.f8rKB.EH4XWO0WSiefDq1XGUX6/wImzUin2aS', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (3, '25204039902', 'Diya', 'Patel', '25204039902@stu.manit.ac.in', '$2a$10$3SoFBYvVXdLIeBRWab3/YudBuBdm9L2uePkhhORn0X4F.ngFu53De', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (4, '25204039903', 'Kabir', 'Verma', '25204039903@stu.manit.ac.in', '$2a$10$A5anPwGp8FNLbMJejy3dq.2vf2WeiKTJ6vtBm8SzeO1JyHjk04xvq', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (5, '25204039904', 'Meera', 'Iyer', '25204039904@stu.manit.ac.in', '$2a$10$.4x5hpgSj13q.nx/DjUZZuMbwm7bAv9fJugAOrEnyhv2447juceoi', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (6, '25204039905', 'Rohan', 'Das', '25204039905@stu.manit.ac.in', '$2a$10$zRjgU5dTfF75c7b7l2mumO8ZvuTpotbJ97uIxpXr92vR2p/YtyLKm', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (7, '25204039906', 'Sana', 'Khan', '25204039906@stu.manit.ac.in', '$2a$10$b4LyX1xR8M/H3t2qbCUPoOkGTpF9Y.WLl7El4a.hS.8cUc50n2SZ6', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (8, '25204039907', 'Vikram', 'Singh', '25204039907@stu.manit.ac.in', '$2a$10$xuyFbH0WYOXe9IYffp/Cx.gTKIuxNSJp1CDM6WCV4LHLdt9mdDAlS', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (9, '25204039908', 'Ananya', 'Gupta', '25204039908@stu.manit.ac.in', '$2a$10$HRIqg6vttFPMzFkF.5t4wevPZsFICGIujLYZuGqnwQAZvGWB58GEu', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (10, '25204039909', 'Ishaan', 'Nair', '25204039909@stu.manit.ac.in', '$2a$10$JyYLeiDtCsokno6hp2J0n.FqIfBO3jUMT1KDb7E1b9VxpaYfsqrfC', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (11, '25204039910', 'Tanvi', 'Joshi', '25204039910@stu.manit.ac.in', '$2a$10$hoBhwCDPs.c9Yp6UMCzSuubw7NQkUi07YZgIb3V64KTFkhpXcSqJm', 'MBC', 'MCA', 2, 'VOTER', NOW(6)),
  (12, 'FAC001', 'Demo', 'Professor', 'demo.professor@stu.manit.ac.in', '$2a$10$PtWaJ7t18mVziMiq.stcM.A3Z9xA.Fx7jpel//IIUR9xfxkypyQGW', 'MBC', 'Faculty', 0, 'VOTER', NOW(6)),
  (13, 'FAC002', 'Sample', 'Faculty', 'sample.faculty@stu.manit.ac.in', '$2a$10$5u6OCDpTUED82Ht8UXm4s.Y3czAgiwN.hi1kbxre2Zbklo4H5zBf.', 'MBC', 'Faculty', 0, 'VOTER', NOW(6));

-- Done. Every other table is intentionally left empty.
