
SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `wr_users`
-- ----------------------------
DROP TABLE IF EXISTS `wr_users`;
CREATE TABLE `wr_users` (
  `userID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `isAdmin` tinyint(4) NOT NULL DEFAULT '0',
  `isDeveloper` tinyint(4) NOT NULL DEFAULT '0',
  `createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for `wr_stored_connections`
-- ----------------------------
DROP TABLE IF EXISTS `wr_stored_connections`;
CREATE TABLE `wr_stored_connections` (
  `storedConnectionID` int(11) NOT NULL AUTO_INCREMENT,
  `datasource` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `dbtype` varchar(255) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`storedConnectionID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for `wr_groups`
-- ----------------------------
DROP TABLE IF EXISTS `wr_groups`;
CREATE TABLE `wr_groups` (
  `groupID` int(11) NOT NULL AUTO_INCREMENT,
  `groupName` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`groupID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for `wr_reports`
-- ----------------------------
DROP TABLE IF EXISTS `wr_reports`;
CREATE TABLE `wr_reports` (
  `reportID` int(11) NOT NULL AUTO_INCREMENT,
  `reportName` varchar(255) NOT NULL,
  `reportHREF` varchar(255) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `storedConnectionID` int(11) DEFAULT NULL,
  `datasource` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `dbtype` varchar(255) DEFAULT NULL,
  `isPublic` tinyint(4) NOT NULL DEFAULT '1',
  `createdOn` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reportID`),
  KEY `fk_reports_1` (`storedConnectionID`),
  CONSTRAINT `fk_reports_1` FOREIGN KEY (`storedConnectionID`) REFERENCES `wr_stored_connections` (`storedConnectionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for `wr_report_groups`
-- ----------------------------
DROP TABLE IF EXISTS `wr_report_groups`;
CREATE TABLE `wr_report_groups` (
  `reportGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `reportID` int(11) NOT NULL,
  `groupID` int(11) NOT NULL,
  PRIMARY KEY (`reportGroupID`),
  KEY `fk_report_groups_1` (`reportID`),
  KEY `fk_report_groups_2` (`groupID`),
  CONSTRAINT `fk_report_groups_2` FOREIGN KEY (`groupID`) REFERENCES `wr_groups` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_report_groups_1` FOREIGN KEY (`reportID`) REFERENCES `wr_reports` (`reportID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Table structure for `wr_report_users`
-- ----------------------------
DROP TABLE IF EXISTS `wr_report_users`;
CREATE TABLE `wr_report_users` (
  `reportUserID` int(11) NOT NULL AUTO_INCREMENT,
  `reportID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  PRIMARY KEY (`reportUserID`),
  KEY `fk_report_users_1` (`reportID`),
  KEY `fk_report_users_2` (`userID`),
  CONSTRAINT `fk_report_users_2` FOREIGN KEY (`userID`) REFERENCES `wr_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_report_users_1` FOREIGN KEY (`reportID`) REFERENCES `wr_reports` (`reportID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- ----------------------------
-- Table structure for `wr_user_groups`
-- ----------------------------
DROP TABLE IF EXISTS `wr_user_groups`;
CREATE TABLE `wr_user_groups` (
  `userGroupID` int(11) NOT NULL AUTO_INCREMENT,
  `userID` int(11) NOT NULL,
  `groupID` int(11) NOT NULL,
  PRIMARY KEY (`userGroupID`),
  KEY `fk_user_groups_1` (`userID`),
  KEY `fk_user_groups_2` (`groupID`),
  CONSTRAINT `fk_user_groups_2` FOREIGN KEY (`groupID`) REFERENCES `wr_groups` (`groupID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_groups_1` FOREIGN KEY (`userID`) REFERENCES `wr_users` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


