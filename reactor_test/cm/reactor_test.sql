-- MySQL dump 10.13  Distrib 5.6.34, for osx10.12 (x86_64)
--
-- Host: 127.0.0.1    Database: reactor_test
-- ------------------------------------------------------
-- Server version	5.6.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `reactor_test`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `reactor_test` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `reactor_test`;

--
-- Table structure for table `default_app_info`
--

DROP TABLE IF EXISTS `default_app_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_app_info` (
  `is_railsified` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_app_info`
--

LOCK TABLES `default_app_info` WRITE;
/*!40000 ALTER TABLE `default_app_info` DISABLE KEYS */;
INSERT INTO `default_app_info` VALUES (1);
/*!40000 ALTER TABLE `default_app_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_attributes`
--

DROP TABLE IF EXISTS `default_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_attributes` (
  `attribute_id` int(11) NOT NULL,
  `attribute_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `attribute_type` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `default_attrx1` (`attribute_name`),
  KEY `default_attrx2` (`attribute_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_attributes`
--

LOCK TABLES `default_attributes` WRITE;
/*!40000 ALTER TABLE `default_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_blob_mappings`
--

DROP TABLE IF EXISTS `default_blob_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_blob_mappings` (
  `blob_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `fingerprint` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`blob_name`),
  KEY `default_bmx1` (`fingerprint`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_blob_mappings`
--

LOCK TABLES `default_blob_mappings` WRITE;
/*!40000 ALTER TABLE `default_blob_mappings` DISABLE KEYS */;
INSERT INTO `default_blob_mappings` VALUES ('Root.jsonObjClassDict','dd929a904002e8dc99d827fb2ff39d834d657e08_333');
/*!40000 ALTER TABLE `default_blob_mappings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_blobs`
--

DROP TABLE IF EXISTS `default_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_blobs` (
  `blob_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `blob_length` int(11) NOT NULL,
  `blob_data` longblob,
  PRIMARY KEY (`blob_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_blobs`
--

LOCK TABLES `default_blobs` WRITE;
/*!40000 ALTER TABLE `default_blobs` DISABLE KEYS */;
INSERT INTO `default_blobs` VALUES ('dd929a904002e8dc99d827fb2ff39d834d657e08_333',333,'{\"attributeGroups\": [{\"attributes\": [\"title\", \"blob\", \"validFrom\", \"validUntil\", \"contentType\", \"channels\"], \"name\": \"baseGroup\", \"title.de\": \"Felder\", \"title.en\": \"Fields\", \"title.es\": \"Campos\", \"title.fr\": \"Champs\", \"title.it\": \"Campi\"}], \"canCreateNewsItems\": 0, \"availableBlobEditors\": [\"internalEditor\"], \"presetAttributes\": {}}');
/*!40000 ALTER TABLE `default_blobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_channels`
--

DROP TABLE IF EXISTS `default_channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_channels` (
  `channel_id` int(11) NOT NULL,
  `channel_name` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`channel_id`),
  UNIQUE KEY `default_chnidx1` (`channel_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_channels`
--

LOCK TABLES `default_channels` WRITE;
/*!40000 ALTER TABLE `default_channels` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_channels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_contents`
--

DROP TABLE IF EXISTS `default_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_contents` (
  `content_id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `sort_key1` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sort_key2` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sort_key3` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sort_key_length1` int(11) DEFAULT NULL,
  `sort_key_length2` int(11) DEFAULT NULL,
  `sort_key_length3` int(11) DEFAULT NULL,
  `sort_type1` int(11) DEFAULT NULL,
  `sort_type2` int(11) DEFAULT NULL,
  `sort_type3` int(11) DEFAULT NULL,
  `content_type` varchar(250) COLLATE utf8_bin NOT NULL,
  `last_changed` char(14) COLLATE utf8_bin NOT NULL,
  `title` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `valid_from` char(14) COLLATE utf8_bin DEFAULT NULL,
  `valid_until` char(14) COLLATE utf8_bin DEFAULT NULL,
  `editor` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `ext_index_col` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`content_id`),
  KEY `default_cntx1` (`object_id`),
  KEY `default_cntx2` (`valid_until`),
  CONSTRAINT `default_cntfk_1` FOREIGN KEY (`object_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_contents`
--

LOCK TABLES `default_contents` WRITE;
/*!40000 ALTER TABLE `default_contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_events`
--

DROP TABLE IF EXISTS `default_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_events` (
  `event_id` int(11) NOT NULL,
  `exec_time` char(14) COLLATE utf8_bin NOT NULL,
  `class_key` varchar(250) COLLATE utf8_bin NOT NULL,
  `identifier` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `in_tran` int(11) NOT NULL,
  PRIMARY KEY (`event_id`),
  KEY `default_evtx1` (`identifier`),
  KEY `default_evtx2` (`class_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_events`
--

LOCK TABLES `default_events` WRITE;
/*!40000 ALTER TABLE `default_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_global_permissions`
--

DROP TABLE IF EXISTS `default_global_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_global_permissions` (
  `permission_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `global_perm_type` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`permission_id`),
  KEY `default_glpmx1` (`user_id`),
  CONSTRAINT `default_glpmfk_1` FOREIGN KEY (`user_id`) REFERENCES `default_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_global_permissions`
--

LOCK TABLES `default_global_permissions` WRITE;
/*!40000 ALTER TABLE `default_global_permissions` DISABLE KEYS */;
INSERT INTO `default_global_permissions` VALUES (1050,1020,'permissionGlobalRoot');
/*!40000 ALTER TABLE `default_global_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_job_logs`
--

DROP TABLE IF EXISTS `default_job_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_job_logs` (
  `job_log_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `exec_start` char(14) COLLATE utf8_bin NOT NULL,
  `exec_end` char(14) COLLATE utf8_bin DEFAULT NULL,
  `exec_result` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`job_log_id`),
  KEY `default_jlgx1` (`job_id`),
  CONSTRAINT `default_jlgfk_1` FOREIGN KEY (`job_id`) REFERENCES `default_jobs` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_job_logs`
--

LOCK TABLES `default_job_logs` WRITE;
/*!40000 ALTER TABLE `default_job_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_job_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_jobs`
--

DROP TABLE IF EXISTS `default_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_jobs` (
  `job_id` int(11) NOT NULL,
  `job_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `category` varchar(250) COLLATE utf8_bin NOT NULL,
  `job_comment` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `title` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `exec_login` varchar(250) COLLATE utf8_bin NOT NULL,
  `exec_perm` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `queue_pos` int(11) NOT NULL,
  `repeat_mode` int(11) DEFAULT NULL,
  `repeat_defs` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `is_active` int(11) NOT NULL,
  PRIMARY KEY (`job_id`),
  UNIQUE KEY `default_jobx3` (`job_name`),
  KEY `default_jobx1` (`queue_pos`),
  KEY `default_jobx2` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_jobs`
--

LOCK TABLES `default_jobs` WRITE;
/*!40000 ALTER TABLE `default_jobs` DISABLE KEYS */;
INSERT INTO `default_jobs` VALUES (1500,'systemPublish','system',NULL,'Publish','root','permissionGlobalRoot',-1,0,NULL,1),(1501,'systemTransferUpdates','system',NULL,'Transfer Updates','root','permissionGlobalRoot',-1,0,NULL,1),(1502,'systemSendReminderNotifications','system',NULL,'Sends Reminder Notifications','root',NULL,-1,0,NULL,1);
/*!40000 ALTER TABLE `default_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_links`
--

DROP TABLE IF EXISTS `default_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_links` (
  `content_id` int(11) NOT NULL,
  `expected_path` varchar(1300) COLLATE utf8_bin DEFAULT NULL,
  `link_class` char(1) COLLATE utf8_bin NOT NULL,
  `link_id` int(11) NOT NULL,
  `sub_object_id` int(11) DEFAULT NULL,
  `sub_mirror_id` int(11) DEFAULT NULL,
  `target` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `title` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(1300) COLLATE utf8_bin DEFAULT NULL,
  `attribute_name` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sourcetag_name` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sourcetag_attr` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `position` int(11) NOT NULL,
  PRIMARY KEY (`link_id`),
  KEY `default_linkx1` (`content_id`),
  KEY `default_linkx2` (`sub_object_id`),
  KEY `default_linkx5` (`sub_mirror_id`),
  CONSTRAINT `default_linkfk_1` FOREIGN KEY (`content_id`) REFERENCES `default_contents` (`content_id`),
  CONSTRAINT `default_linkfk_2` FOREIGN KEY (`sub_object_id`) REFERENCES `default_objects` (`object_id`),
  CONSTRAINT `default_linkfk_3` FOREIGN KEY (`sub_mirror_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_links`
--

LOCK TABLES `default_links` WRITE;
/*!40000 ALTER TABLE `default_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_logins`
--

DROP TABLE IF EXISTS `default_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_logins` (
  `login_id` int(11) NOT NULL,
  `login` varchar(250) COLLATE utf8_bin NOT NULL,
  `timestamp` char(14) COLLATE utf8_bin NOT NULL,
  `interface` char(1) COLLATE utf8_bin NOT NULL,
  `session_id` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`login_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_logins`
--

LOCK TABLES `default_logins` WRITE;
/*!40000 ALTER TABLE `default_logins` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_logins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_logs`
--

DROP TABLE IF EXISTS `default_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_logs` (
  `log_id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `log_time` char(14) COLLATE utf8_bin NOT NULL,
  `log_type` int(11) NOT NULL,
  `log_user_login` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `log_text` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `log_receiver` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  KEY `default_logsx1` (`object_id`),
  CONSTRAINT `default_logsfk_1` FOREIGN KEY (`object_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_logs`
--

LOCK TABLES `default_logs` WRITE;
/*!40000 ALTER TABLE `default_logs` DISABLE KEYS */;
INSERT INTO `default_logs` VALUES (2011,2001,'20130308084511',1,'root','2010,global',NULL),(2021,2001,'20130308084511',1,'root','2020,mastertemplate',NULL),(2082,2001,'20130308084513',1,'root','2081,_named_links',NULL),(2096,2001,'20180201115402',14,'root',NULL,NULL),(2106,2001,'20180201115403',2,'root','2020,mastertemplate',NULL),(2113,2001,'20180201115403',2,'root','2010,global',NULL),(2114,2001,'20180201115403',2,'root','2081,_named_links',NULL);
/*!40000 ALTER TABLE `default_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_maxids`
--

DROP TABLE IF EXISTS `default_maxids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_maxids` (
  `maxid` int(11) NOT NULL,
  PRIMARY KEY (`maxid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_maxids`
--

LOCK TABLES `default_maxids` WRITE;
/*!40000 ALTER TABLE `default_maxids` DISABLE KEYS */;
INSERT INTO `default_maxids` VALUES (2114);
/*!40000 ALTER TABLE `default_maxids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_news`
--

DROP TABLE IF EXISTS `default_news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_news` (
  `news_id` int(11) NOT NULL,
  `channel_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `object_id` int(11) NOT NULL,
  `valid_from` char(14) COLLATE utf8_bin NOT NULL,
  `valid_until` char(14) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`news_id`),
  KEY `default_newsx1` (`object_id`),
  KEY `default_newsx2` (`channel_name`),
  KEY `default_newsx3` (`valid_from`),
  KEY `default_newsx4` (`valid_until`),
  CONSTRAINT `default_newsfk_1` FOREIGN KEY (`object_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_news`
--

LOCK TABLES `default_news` WRITE;
/*!40000 ALTER TABLE `default_news` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_news` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_obj_class_attrs`
--

DROP TABLE IF EXISTS `default_obj_class_attrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_obj_class_attrs` (
  `obj_class_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  KEY `default_ocax1` (`obj_class_id`),
  KEY `default_ocax2` (`attribute_id`),
  CONSTRAINT `default_ocafk_1` FOREIGN KEY (`obj_class_id`) REFERENCES `default_obj_classes` (`obj_class_id`),
  CONSTRAINT `default_ocafk_2` FOREIGN KEY (`attribute_id`) REFERENCES `default_attributes` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_obj_class_attrs`
--

LOCK TABLES `default_obj_class_attrs` WRITE;
/*!40000 ALTER TABLE `default_obj_class_attrs` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_obj_class_attrs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_obj_classes`
--

DROP TABLE IF EXISTS `default_obj_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_obj_classes` (
  `obj_class_id` int(11) NOT NULL,
  `obj_class_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `is_enabled` int(11) NOT NULL,
  `obj_type` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`obj_class_id`),
  UNIQUE KEY `default_obcx1` (`obj_class_name`),
  KEY `default_obcx2` (`is_enabled`),
  KEY `default_obcx3` (`obj_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_obj_classes`
--

LOCK TABLES `default_obj_classes` WRITE;
/*!40000 ALTER TABLE `default_obj_classes` DISABLE KEYS */;
INSERT INTO `default_obj_classes` VALUES (2095,'Root',1,'publication');
/*!40000 ALTER TABLE `default_obj_classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_objects`
--

DROP TABLE IF EXISTS `default_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_objects` (
  `committed_cont_id` int(11) DEFAULT NULL,
  `suppress_export` int(11) DEFAULT NULL,
  `edited_content_id` int(11) DEFAULT NULL,
  `obj_class` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `obj_type_code` char(1) COLLATE utf8_bin NOT NULL,
  `object_id` int(11) NOT NULL,
  `object_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `parent_object_id` int(11) DEFAULT NULL,
  `original_object_id` int(11) DEFAULT NULL,
  `released_cont_id` int(11) DEFAULT NULL,
  `sort_value` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sort_value2` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `sort_value3` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `valid_from` char(14) COLLATE utf8_bin DEFAULT NULL,
  `valid_until` char(14) COLLATE utf8_bin DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `workflow_name` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `created` char(14) COLLATE utf8_bin DEFAULT NULL,
  `source_last_changed` char(14) COLLATE utf8_bin DEFAULT NULL,
  `reminder_from` char(14) COLLATE utf8_bin DEFAULT NULL,
  `reminder_comment` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `permalink` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`object_id`),
  UNIQUE KEY `default_objx1` (`parent_object_id`,`object_name`),
  KEY `default_objx2` (`parent_object_id`),
  KEY `default_objx3` (`released_cont_id`),
  KEY `default_objx4` (`edited_content_id`),
  KEY `default_objx5` (`committed_cont_id`),
  KEY `default_objx6` (`original_object_id`),
  KEY `default_objx7` (`permalink`),
  CONSTRAINT `default_objfk_1` FOREIGN KEY (`parent_object_id`) REFERENCES `default_objects` (`object_id`),
  CONSTRAINT `default_objfk_2` FOREIGN KEY (`released_cont_id`) REFERENCES `default_contents` (`content_id`),
  CONSTRAINT `default_objfk_3` FOREIGN KEY (`edited_content_id`) REFERENCES `default_contents` (`content_id`),
  CONSTRAINT `default_objfk_4` FOREIGN KEY (`committed_cont_id`) REFERENCES `default_contents` (`content_id`),
  CONSTRAINT `default_objfk_5` FOREIGN KEY (`original_object_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_objects`
--

LOCK TABLES `default_objects` WRITE;
/*!40000 ALTER TABLE `default_objects` DISABLE KEYS */;
INSERT INTO `default_objects` VALUES (NULL,0,NULL,'Root','5',2001,'ROOTPUB',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `default_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_objs`
--

DROP TABLE IF EXISTS `default_objs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_objs` (
  `obj_id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8_bin NOT NULL,
  `parent_obj_id` int(11) DEFAULT NULL,
  `permalink` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `obj_class` varchar(250) COLLATE utf8_bin NOT NULL,
  `suppress_export` int(11) NOT NULL,
  `obj_type_code` char(1) COLLATE utf8_bin NOT NULL,
  `last_changed` char(14) COLLATE utf8_bin DEFAULT NULL,
  `attr_defs` longtext COLLATE utf8_bin,
  `attr_values` longtext COLLATE utf8_bin,
  `path` varchar(1300) COLLATE utf8_bin DEFAULT NULL,
  `file_extension` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `is_edited` int(11) NOT NULL,
  `is_released` int(11) NOT NULL,
  `valid_from` char(14) COLLATE utf8_bin DEFAULT NULL,
  `valid_until` char(14) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`obj_id`),
  UNIQUE KEY `default_rox1` (`parent_obj_id`,`name`),
  KEY `default_rox2` (`parent_obj_id`),
  KEY `default_rox3` (`permalink`),
  KEY `default_rox4` (`name`),
  KEY `default_rox5` (`obj_class`),
  KEY `default_rox6` (`obj_type_code`),
  KEY `default_rox7` (`last_changed`),
  KEY `default_rox8` (`obj_type_code`,`last_changed`),
  KEY `default_rox9` (`suppress_export`),
  KEY `default_rox10` (`path`(255)),
  KEY `default_rox11` (`valid_from`),
  KEY `default_rox12` (`valid_until`),
  KEY `default_rox13` (`valid_from`,`valid_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_objs`
--

LOCK TABLES `default_objs` WRITE;
/*!40000 ALTER TABLE `default_objs` DISABLE KEYS */;
INSERT INTO `default_objs` VALUES (2001,'ROOTPUB',NULL,NULL,'Root',0,'5',NULL,NULL,NULL,'/',NULL,0,0,NULL,NULL);
/*!40000 ALTER TABLE `default_objs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_permissions`
--

DROP TABLE IF EXISTS `default_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_permissions` (
  `permission_id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `user_login` varchar(250) COLLATE utf8_bin NOT NULL,
  `permission_type` int(11) NOT NULL,
  PRIMARY KEY (`permission_id`),
  KEY `default_permx1` (`object_id`),
  CONSTRAINT `default_permfk_1` FOREIGN KEY (`object_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_permissions`
--

LOCK TABLES `default_permissions` WRITE;
/*!40000 ALTER TABLE `default_permissions` DISABLE KEYS */;
INSERT INTO `default_permissions` VALUES (2094,2001,'not_root_group',4);
/*!40000 ALTER TABLE `default_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_preview_objs`
--

DROP TABLE IF EXISTS `default_preview_objs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_preview_objs` (
  `obj_id` int(11) NOT NULL,
  `name` varchar(250) COLLATE utf8_bin NOT NULL,
  `parent_obj_id` int(11) DEFAULT NULL,
  `permalink` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `obj_class` varchar(250) COLLATE utf8_bin NOT NULL,
  `suppress_export` int(11) NOT NULL,
  `obj_type_code` char(1) COLLATE utf8_bin NOT NULL,
  `last_changed` char(14) COLLATE utf8_bin DEFAULT NULL,
  `attr_defs` longtext COLLATE utf8_bin,
  `attr_values` longtext COLLATE utf8_bin,
  `path` varchar(1300) COLLATE utf8_bin DEFAULT NULL,
  `file_extension` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `is_edited` int(11) NOT NULL,
  `is_released` int(11) NOT NULL,
  `valid_from` char(14) COLLATE utf8_bin DEFAULT NULL,
  `valid_until` char(14) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`obj_id`),
  UNIQUE KEY `default_eox1` (`parent_obj_id`,`name`),
  KEY `default_eox2` (`parent_obj_id`),
  KEY `default_eox3` (`permalink`),
  KEY `default_eox4` (`name`),
  KEY `default_eox5` (`obj_class`),
  KEY `default_eox6` (`obj_type_code`),
  KEY `default_eox7` (`last_changed`),
  KEY `default_eox8` (`obj_type_code`,`last_changed`),
  KEY `default_eox9` (`suppress_export`),
  KEY `default_eox10` (`path`(255)),
  KEY `default_eox11` (`valid_from`),
  KEY `default_eox12` (`valid_until`),
  KEY `default_eox13` (`valid_from`,`valid_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_preview_objs`
--

LOCK TABLES `default_preview_objs` WRITE;
/*!40000 ALTER TABLE `default_preview_objs` DISABLE KEYS */;
INSERT INTO `default_preview_objs` VALUES (2001,'ROOTPUB',NULL,NULL,'Root',0,'5',NULL,NULL,NULL,'/',NULL,0,0,NULL,NULL);
/*!40000 ALTER TABLE `default_preview_objs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_rails`
--

DROP TABLE IF EXISTS `default_rails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_rails` (
  `obj_id` int(11) NOT NULL,
  `railsify` int(11) NOT NULL,
  PRIMARY KEY (`obj_id`),
  KEY `default_rax1` (`railsify`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_rails`
--

LOCK TABLES `default_rails` WRITE;
/*!40000 ALTER TABLE `default_rails` DISABLE KEYS */;
INSERT INTO `default_rails` VALUES (2001,0);
/*!40000 ALTER TABLE `default_rails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_reminder_recipients`
--

DROP TABLE IF EXISTS `default_reminder_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_reminder_recipients` (
  `id` int(11) NOT NULL,
  `object_id` int(11) NOT NULL,
  `user_login` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `group_name` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `default_remrex1` (`object_id`),
  KEY `default_remrex2` (`user_login`),
  KEY `default_remrex3` (`group_name`),
  CONSTRAINT `default_rmrcfk_1` FOREIGN KEY (`object_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_reminder_recipients`
--

LOCK TABLES `default_reminder_recipients` WRITE;
/*!40000 ALTER TABLE `default_reminder_recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_reminder_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_restore_data`
--

DROP TABLE IF EXISTS `default_restore_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_restore_data` (
  `restore_id` int(11) NOT NULL,
  `type` varchar(250) COLLATE utf8_bin NOT NULL,
  `entity_id` varchar(250) COLLATE utf8_bin NOT NULL,
  `entity_type` varchar(250) COLLATE utf8_bin NOT NULL,
  `data` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`restore_id`),
  KEY `default_rstx1` (`entity_id`),
  KEY `default_rstx2` (`entity_type`),
  KEY `default_rstx3` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_restore_data`
--

LOCK TABLES `default_restore_data` WRITE;
/*!40000 ALTER TABLE `default_restore_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_restore_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_restore_state`
--

DROP TABLE IF EXISTS `default_restore_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_restore_state` (
  `restore_state_id` int(11) NOT NULL,
  `entity_count` int(11) DEFAULT NULL,
  `offset` int(11) DEFAULT NULL,
  `finished` int(11) NOT NULL,
  `file_name` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `dumper_class` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`restore_state_id`),
  KEY `default_rssx1` (`dumper_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_restore_state`
--

LOCK TABLES `default_restore_state` WRITE;
/*!40000 ALTER TABLE `default_restore_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_restore_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_schema_info`
--

DROP TABLE IF EXISTS `default_schema_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_schema_info` (
  `version` int(11) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_schema_info`
--

LOCK TABLES `default_schema_info` WRITE;
/*!40000 ALTER TABLE `default_schema_info` DISABLE KEYS */;
INSERT INTO `default_schema_info` VALUES (153);
/*!40000 ALTER TABLE `default_schema_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_streaming_tickets`
--

DROP TABLE IF EXISTS `default_streaming_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_streaming_tickets` (
  `ticket_id` int(11) NOT NULL,
  `timestamp` char(14) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`ticket_id`),
  KEY `default_strx1` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_streaming_tickets`
--

LOCK TABLES `default_streaming_tickets` WRITE;
/*!40000 ALTER TABLE `default_streaming_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_streaming_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_tasks`
--

DROP TABLE IF EXISTS `default_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_tasks` (
  `obj_id` int(11) NOT NULL,
  `task_type` char(1) COLLATE utf8_bin NOT NULL,
  `title` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `user_login` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `group_name` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `time_stamp` char(14) COLLATE utf8_bin DEFAULT NULL,
  `task_comment` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `task_id` int(11) NOT NULL,
  PRIMARY KEY (`task_id`),
  KEY `default_taskx1` (`obj_id`),
  KEY `default_taskx2` (`user_login`),
  KEY `default_taskx3` (`group_name`),
  KEY `default_taskx4` (`task_type`),
  CONSTRAINT `default_taskfk_1` FOREIGN KEY (`obj_id`) REFERENCES `default_objects` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_tasks`
--

LOCK TABLES `default_tasks` WRITE;
/*!40000 ALTER TABLE `default_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_update_records`
--

DROP TABLE IF EXISTS `default_update_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_update_records` (
  `update_record_id` int(11) NOT NULL,
  `timestamp` char(14) COLLATE utf8_bin NOT NULL,
  `sec_serial_num` int(11) NOT NULL,
  `update_type` int(11) NOT NULL,
  PRIMARY KEY (`update_record_id`),
  KEY `default_urx1` (`timestamp`,`sec_serial_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_update_records`
--

LOCK TABLES `default_update_records` WRITE;
/*!40000 ALTER TABLE `default_update_records` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_update_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_user_grp_assgts`
--

DROP TABLE IF EXISTS `default_user_grp_assgts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_user_grp_assgts` (
  `user_grp_assgt_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `sub_user_id` int(11) NOT NULL,
  PRIMARY KEY (`user_grp_assgt_id`),
  KEY `default_ugax1` (`user_id`),
  KEY `default_ugax2` (`sub_user_id`),
  CONSTRAINT `default_ugafk_1` FOREIGN KEY (`user_id`) REFERENCES `default_users` (`user_id`),
  CONSTRAINT `default_ugafk_2` FOREIGN KEY (`sub_user_id`) REFERENCES `default_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_user_grp_assgts`
--

LOCK TABLES `default_user_grp_assgts` WRITE;
/*!40000 ALTER TABLE `default_user_grp_assgts` DISABLE KEYS */;
INSERT INTO `default_user_grp_assgts` VALUES (1040,1020,1030),(2093,2091,2092);
/*!40000 ALTER TABLE `default_user_grp_assgts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_users`
--

DROP TABLE IF EXISTS `default_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_users` (
  `user_id` int(11) NOT NULL,
  `user_login` varchar(250) COLLATE utf8_bin NOT NULL,
  `user_password` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `user_realname` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `user_email` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `user_locked` int(11) NOT NULL,
  `user_isgroup` int(11) NOT NULL,
  `default_grp_id` int(11) DEFAULT NULL,
  `owner_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `default_usrx1` (`user_login`),
  KEY `default_usrx2` (`owner_user_id`),
  KEY `default_usrx3` (`default_grp_id`),
  CONSTRAINT `default_usrfk_1` FOREIGN KEY (`owner_user_id`) REFERENCES `default_users` (`user_id`),
  CONSTRAINT `default_usrfk_2` FOREIGN KEY (`default_grp_id`) REFERENCES `default_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_users`
--

LOCK TABLES `default_users` WRITE;
/*!40000 ALTER TABLE `default_users` DISABLE KEYS */;
INSERT INTO `default_users` VALUES (1020,'admins',NULL,'Administrators',NULL,0,1,NULL,NULL),(1030,'root',NULL,'Superuser','postmaster@localhost',0,0,1020,NULL),(2091,'not_root_group',NULL,NULL,NULL,0,1,NULL,1030),(2092,'not_root','$apr1$qG$bFW7bzlicZbmxjj8gJFtL0',NULL,NULL,0,0,2091,1030);
/*!40000 ALTER TABLE `default_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_usr_attr_enum_vals`
--

DROP TABLE IF EXISTS `default_usr_attr_enum_vals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_usr_attr_enum_vals` (
  `attr_enum_val_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  `enum_value` varchar(250) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`attr_enum_val_id`),
  UNIQUE KEY `default_uaevx1` (`attribute_id`,`enum_value`),
  KEY `default_uaevx2` (`attribute_id`),
  CONSTRAINT `default_uaevfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `default_usr_attributes` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_usr_attr_enum_vals`
--

LOCK TABLES `default_usr_attr_enum_vals` WRITE;
/*!40000 ALTER TABLE `default_usr_attr_enum_vals` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_usr_attr_enum_vals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_usr_attr_values`
--

DROP TABLE IF EXISTS `default_usr_attr_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_usr_attr_values` (
  `attribute_id` int(11) NOT NULL,
  `attribute_value_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `value_enum` int(11) DEFAULT NULL,
  `value_string` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`attribute_value_id`),
  KEY `default_uavx1` (`attribute_id`),
  KEY `default_uavx2` (`user_id`),
  KEY `default_uavx3` (`value_enum`),
  CONSTRAINT `default_uavfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `default_usr_attributes` (`attribute_id`),
  CONSTRAINT `default_uavfk_2` FOREIGN KEY (`user_id`) REFERENCES `default_users` (`user_id`),
  CONSTRAINT `default_uavfk_3` FOREIGN KEY (`value_enum`) REFERENCES `default_usr_attr_enum_vals` (`attr_enum_val_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_usr_attr_values`
--

LOCK TABLES `default_usr_attr_values` WRITE;
/*!40000 ALTER TABLE `default_usr_attr_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_usr_attr_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_usr_attributes`
--

DROP TABLE IF EXISTS `default_usr_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_usr_attributes` (
  `attribute_id` int(11) NOT NULL,
  `attribute_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `attribute_type` int(11) NOT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `default_uax1` (`attribute_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_usr_attributes`
--

LOCK TABLES `default_usr_attributes` WRITE;
/*!40000 ALTER TABLE `default_usr_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_usr_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_workflow_attrs`
--

DROP TABLE IF EXISTS `default_workflow_attrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_workflow_attrs` (
  `workflow_id` int(11) NOT NULL,
  `attribute_id` int(11) NOT NULL,
  KEY `default_wfax1` (`workflow_id`),
  KEY `default_wfax2` (`attribute_id`),
  CONSTRAINT `default_wfafk_1` FOREIGN KEY (`workflow_id`) REFERENCES `default_workflows` (`workflow_id`),
  CONSTRAINT `default_wfafk_2` FOREIGN KEY (`attribute_id`) REFERENCES `default_attributes` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_workflow_attrs`
--

LOCK TABLES `default_workflow_attrs` WRITE;
/*!40000 ALTER TABLE `default_workflow_attrs` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_workflow_attrs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `default_workflows`
--

DROP TABLE IF EXISTS `default_workflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_workflows` (
  `workflow_id` int(11) NOT NULL,
  `workflow_name` varchar(250) COLLATE utf8_bin NOT NULL,
  `is_enabled` int(11) NOT NULL,
  PRIMARY KEY (`workflow_id`),
  UNIQUE KEY `default_wkfx1` (`workflow_name`),
  KEY `default_wkfx2` (`is_enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `default_workflows`
--

LOCK TABLES `default_workflows` WRITE;
/*!40000 ALTER TABLE `default_workflows` DISABLE KEYS */;
/*!40000 ALTER TABLE `default_workflows` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-02-22 12:38:14
