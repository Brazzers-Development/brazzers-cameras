CREATE TABLE IF NOT EXISTS `player_cameras` (
  `camid` varchar(255) NOT NULL,
  `name` text DEFAULT NULL,
  `owner` varchar(50) DEFAULT NULL,
  `access` text DEFAULT '[]',
  `coords` text DEFAULT NULL,
  `model` text DEFAULT NULL,
  `time` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`camid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;