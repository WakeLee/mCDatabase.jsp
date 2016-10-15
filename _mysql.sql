DROP TABLE IF EXISTS `mctable`;
CREATE TABLE `mctable` 
(
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  
  `m_tinyint` tinyint(4) DEFAULT NULL,
  `m_smallint` smallint(5) unsigned DEFAULT NULL,
  `m_int` int(10) unsigned DEFAULT NULL,
  `m_bigint` bigint(20) unsigned DEFAULT NULL,
  
  `m_double` char(255) DEFAULT NULL,
  
  `m_char5` char(5) DEFAULT NULL,
  `m_varchar5` varchar(5) DEFAULT NULL,
  `m_text` text DEFAULT NULL,
  
  `m_datetime` datetime DEFAULT NULL,

  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
