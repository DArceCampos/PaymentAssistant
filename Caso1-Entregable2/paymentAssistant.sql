-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema paymentdb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `paymentdb` ;

-- -----------------------------------------------------
-- Schema paymentdb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `paymentdb` DEFAULT CHARACTER SET utf8 ;
USE `paymentdb` ;

-- -----------------------------------------------------
-- Table `paymentdb`.`payment_currency`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_currency` (
  `currencyid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(25) NOT NULL,
  `acronym` VARCHAR(5) NOT NULL,
  `symbol` VARCHAR(1) NOT NULL,
  PRIMARY KEY (`currencyid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_countries`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_countries` (
  `countryid` TINYINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `language` VARCHAR(7) NULL,
  `currencyid` INT NOT NULL,
  PRIMARY KEY (`countryid`),
  INDEX `fk_payment_countries_payment_currency1_idx` (`currencyid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_countries_payment_currency1`
    FOREIGN KEY (`currencyid`)
    REFERENCES `paymentdb`.`payment_currency` (`currencyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_states`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_states` (
  `stateid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `countryid` TINYINT NOT NULL,
  PRIMARY KEY (`stateid`),
  INDEX `fk_payment_states_payment_countries1_idx` (`countryid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_states_payment_countries1`
    FOREIGN KEY (`countryid`)
    REFERENCES `paymentdb`.`payment_countries` (`countryid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_cities`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_cities` (
  `cityid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL,
  `stateid` INT NOT NULL,
  PRIMARY KEY (`cityid`),
  INDEX `fk_payment_cities_payment_states1_idx` (`stateid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_cities_payment_states1`
    FOREIGN KEY (`stateid`)
    REFERENCES `paymentdb`.`payment_states` (`stateid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_addresses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_addresses` (
  `addressid` INT NOT NULL AUTO_INCREMENT,
  `line1` VARCHAR(200) NULL,
  `line2` VARCHAR(200) NULL,
  `zipcode` VARCHAR(9) NOT NULL,
  `cityid` INT NOT NULL,
  `geoposition` GEOMETRY NOT NULL,
  PRIMARY KEY (`addressid`),
  INDEX `fk_payment_addresses_payment_cities1_idx` (`cityid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_addresses_payment_cities1`
    FOREIGN KEY (`cityid`)
    REFERENCES `paymentdb`.`payment_cities` (`cityid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_company`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_company` (
  `companyid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `type` VARCHAR(45) NULL,
  `phonenumber` VARCHAR(15) NULL,
  `email` VARCHAR(320) NULL,
  `addressid` INT NOT NULL,
  PRIMARY KEY (`companyid`),
  INDEX `fk_payment_company_payment_addresses1_idx` (`addressid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_company_payment_addresses1`
    FOREIGN KEY (`addressid`)
    REFERENCES `paymentdb`.`payment_addresses` (`addressid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_users` (
  `userid` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(80) NOT NULL,
  `firstname` VARCHAR(50) NOT NULL,
  `lastname` VARCHAR(50) NOT NULL,
  `birthday` DATE NOT NULL,
  `password` VARBINARY(250) NULL,
  `companyid` INT NULL,
  PRIMARY KEY (`userid`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  INDEX `fk_payment_users_payment_company1_idx` (`companyid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_users_payment_company1`
    FOREIGN KEY (`companyid`)
    REFERENCES `paymentdb`.`payment_company` (`companyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_roles` (
  `roleid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`roleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_modules`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_modules` (
  `moduleid` TINYINT(8) NOT NULL,
  `name` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`moduleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_permissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_permissions` (
  `permissionid` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(100) NOT NULL,
  `code` VARCHAR(10) NOT NULL,
  `moduleid` TINYINT(8) NOT NULL,
  PRIMARY KEY (`permissionid`),
  INDEX `fk_payment_permissions_payment_modules1_idx` (`moduleid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_permissions_payment_modules1`
    FOREIGN KEY (`moduleid`)
    REFERENCES `paymentdb`.`payment_modules` (`moduleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_userpermissions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_userpermissions` (
  `rolepermissionid` INT NOT NULL AUTO_INCREMENT,
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  `lastupdate` DATETIME NOT NULL DEFAULT NOW(),
  `username` VARCHAR(50) NOT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `userid` INT NOT NULL,
  `permissionid` INT NOT NULL,
  PRIMARY KEY (`rolepermissionid`),
  INDEX `fk_payment_userpermissions_payment_users_idx` (`userid` ASC) VISIBLE,
  INDEX `fk_payment_userpermissions_payment_permissions1_idx` (`permissionid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_userpermissions_payment_users`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_userpermissions_payment_permissions1`
    FOREIGN KEY (`permissionid`)
    REFERENCES `paymentdb`.`payment_permissions` (`permissionid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_rolespermission`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_rolespermission` (
  `rolepermissionid` INT NOT NULL AUTO_INCREMENT,
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  `lastupdate` DATETIME NOT NULL DEFAULT NOW(),
  `username` VARCHAR(50) NOT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `roleid` INT NOT NULL,
  `permissionid` INT NOT NULL,
  PRIMARY KEY (`rolepermissionid`),
  INDEX `fk_payment_rolespermission_payment_roles1_idx` (`roleid` ASC) VISIBLE,
  INDEX `fk_payment_rolespermission_payment_permissions1_idx` (`permissionid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_rolespermission_payment_roles1`
    FOREIGN KEY (`roleid`)
    REFERENCES `paymentdb`.`payment_roles` (`roleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_rolespermission_payment_permissions1`
    FOREIGN KEY (`permissionid`)
    REFERENCES `paymentdb`.`payment_permissions` (`permissionid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_usersroles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_usersroles` (
  `payment_roles_roleid` INT NOT NULL,
  `payment_users_userid` INT NOT NULL,
  `lastupdate` DATETIME NOT NULL DEFAULT NOW(),
  `username` VARCHAR(50) NOT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `enabled` BIT NOT NULL DEFAULT 1,
  `deleted` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`payment_roles_roleid`, `payment_users_userid`),
  INDEX `fk_payment_roles_has_payment_users_payment_users1_idx` (`payment_users_userid` ASC) VISIBLE,
  INDEX `fk_payment_roles_has_payment_users_payment_roles1_idx` (`payment_roles_roleid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_roles_has_payment_users_payment_roles1`
    FOREIGN KEY (`payment_roles_roleid`)
    REFERENCES `paymentdb`.`payment_roles` (`roleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_roles_has_payment_users_payment_users1`
    FOREIGN KEY (`payment_users_userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_authplatforms`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_authplatforms` (
  `authplatformid` TINYINT NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  `secretkey` VARBINARY(128) NOT NULL,
  `key` VARBINARY(128) NOT NULL,
  `iconurl` VARCHAR(200) NULL,
  PRIMARY KEY (`authplatformid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_authsession`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_authsession` (
  `authsessionid` INT NOT NULL AUTO_INCREMENT,
  `sessionid` VARBINARY(16) NOT NULL,
  `externaluser` VARBINARY(16) NOT NULL,
  `token` VARBINARY(128) NOT NULL,
  `refreshtoken` DATETIME NOT NULL DEFAULT NOW(),
  `userid` INT NOT NULL,
  `authplatformid` TINYINT NOT NULL,
  PRIMARY KEY (`authsessionid`),
  INDEX `fk_payment_authsession_payment_users1_idx` (`userid` ASC) VISIBLE,
  INDEX `fk_payment_authsession_payment_authplatforms1_idx` (`authplatformid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_authsession_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_authsession_payment_authplatforms1`
    FOREIGN KEY (`authplatformid`)
    REFERENCES `paymentdb`.`payment_authplatforms` (`authplatformid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_mediatypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_mediatypes` (
  `mediatypeid` TINYINT NOT NULL,
  `name` VARCHAR(30) NOT NULL,
  `playerimpl` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`mediatypeid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_mediafiles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_mediafiles` (
  `mediafileid` INT NOT NULL AUTO_INCREMENT,
  `mediapath` VARCHAR(300) NOT NULL,
  `deleted` BIT NOT NULL DEFAULT 0,
  `lastupdate` DATETIME NOT NULL DEFAULT NOW(),
  `userid` INT NOT NULL,
  `mediatypeid` TINYINT NOT NULL,
  `sizeMB` INT NOT NULL,
  `encoding` VARCHAR(20) NOT NULL,
  `samplerate` INT NOT NULL,
  `languagecode` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`mediafileid`),
  INDEX `fk_payment_mediafiles_payment_users1_idx` (`userid` ASC) VISIBLE,
  INDEX `fk_payment_mediafiles_pets_mediatypes1_idx` (`mediatypeid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_mediafiles_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_mediafiles_pets_mediatypes1`
    FOREIGN KEY (`mediatypeid`)
    REFERENCES `paymentdb`.`payment_mediatypes` (`mediatypeid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_useraddress`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_useraddress` (
  `userid` INT NOT NULL,
  `addressid` INT NOT NULL,
  `useraddressid` INT NOT NULL,
  PRIMARY KEY (`userid`, `addressid`, `useraddressid`),
  INDEX `fk_payment_users_has_payment_addresses_payment_addresses1_idx` (`addressid` ASC) VISIBLE,
  INDEX `fk_payment_users_has_payment_addresses_payment_users1_idx` (`userid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_users_has_payment_addresses_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_users_has_payment_addresses_payment_addresses1`
    FOREIGN KEY (`addressid`)
    REFERENCES `paymentdb`.`payment_addresses` (`addressid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_services`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_services` (
  `serviceid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `keywords` MEDIUMTEXT NOT NULL,
  `category` VARCHAR(45) NOT NULL,
  `description` TINYTEXT NULL,
  PRIMARY KEY (`serviceid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_userinfotypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_userinfotypes` (
  `userinfotypesid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`userinfotypesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_paymentmethods`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_paymentmethods` (
  `methodid` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `APIURL` VARCHAR(225) NOT NULL,
  `secretkey` VARBINARY(128) NOT NULL,
  `key` VARBINARY(128) NOT NULL,
  `logoiconurl` VARCHAR(225) NULL,
  `enabled` BIT NOT NULL DEFAULT 0,
  PRIMARY KEY (`methodid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_userinfo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_userinfo` (
  `userinfoid` INT NOT NULL AUTO_INCREMENT,
  `value` VARCHAR(100) NULL,
  `enabled` BIT NOT NULL DEFAULT 0,
  `lastupdate` DATETIME NULL,
  `userid` INT NOT NULL,
  `userinfotypesid` INT NOT NULL,
  `methodid` INT NOT NULL,
  PRIMARY KEY (`userinfoid`),
  INDEX `fk_payment_userinfo_payment_users1_idx` (`userid` ASC) VISIBLE,
  INDEX `fk_payment_userinfo_payment_userinfotypes1_idx` (`userinfotypesid` ASC) VISIBLE,
  INDEX `fk_payment_userinfo_payment_paymentmethods1_idx` (`methodid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_userinfo_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_userinfo_payment_userinfotypes1`
    FOREIGN KEY (`userinfotypesid`)
    REFERENCES `paymentdb`.`payment_userinfotypes` (`userinfotypesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_userinfo_payment_paymentmethods1`
    FOREIGN KEY (`methodid`)
    REFERENCES `paymentdb`.`payment_paymentmethods` (`methodid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_servicesuserinfo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_servicesuserinfo` (
  `servicesuserinfoid` INT NOT NULL AUTO_INCREMENT,
  `serviceid` INT NOT NULL,
  `userinfoid` INT NOT NULL,
  PRIMARY KEY (`servicesuserinfoid`, `serviceid`, `userinfoid`),
  INDEX `fk_payment_services_has_payment_userinfo_payment_userinfo1_idx` (`userinfoid` ASC) VISIBLE,
  INDEX `fk_payment_services_has_payment_userinfo_payment_services1_idx` (`serviceid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_services_has_payment_userinfo_payment_services1`
    FOREIGN KEY (`serviceid`)
    REFERENCES `paymentdb`.`payment_services` (`serviceid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_services_has_payment_userinfo_payment_userinfo1`
    FOREIGN KEY (`userinfoid`)
    REFERENCES `paymentdb`.`payment_userinfo` (`userinfoid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_userservices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_userservices` (
  `userserviceid` INT NOT NULL AUTO_INCREMENT,
  `userid` INT NOT NULL,
  `serviceid` INT NOT NULL,
  PRIMARY KEY (`userserviceid`, `userid`, `serviceid`),
  INDEX `fk_payment_users_has_payment_services_payment_services1_idx` (`serviceid` ASC) VISIBLE,
  INDEX `fk_payment_users_has_payment_services_payment_users1_idx` (`userid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_users_has_payment_services_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_users_has_payment_services_payment_services1`
    FOREIGN KEY (`serviceid`)
    REFERENCES `paymentdb`.`payment_services` (`serviceid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_recording`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_recording` (
  `recordingid` INT NOT NULL AUTO_INCREMENT,
  `starttime` DATETIME NOT NULL DEFAULT NOW(),
  `endtime` DATETIME NOT NULL DEFAULT NOW(),
  `duration` INT NOT NULL,
  `status` ENUM("In progress", "Done", "Failed") NOT NULL,
  `audioquality` ENUM("High", "Medium", "Low") NOT NULL,
  `source` VARCHAR(20) NOT NULL,
  `mediafileid` INT NOT NULL,
  PRIMARY KEY (`recordingid`),
  INDEX `fk_payment_recording_payment_mediafiles1_idx` (`mediafileid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_recording_payment_mediafiles1`
    FOREIGN KEY (`mediafileid`)
    REFERENCES `paymentdb`.`payment_mediafiles` (`mediafileid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_detectedcommands`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_detectedcommands` (
  `detectedcommandsid` INT NOT NULL AUTO_INCREMENT,
  `keywords` MEDIUMTEXT NOT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`detectedcommandsid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_AIprocessings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_AIprocessings` (
  `AIprocessingid` INT NOT NULL AUTO_INCREMENT,
  `processingtype` VARCHAR(30) NOT NULL,
  `starttime` DATETIME NOT NULL DEFAULT NOW(),
  `endtime` DATETIME NOT NULL DEFAULT NOW(),
  `status` VARCHAR(20) NOT NULL,
  `result` TINYTEXT NOT NULL,
  `recordingid` INT NULL,
  `detectedcommandsid` INT NOT NULL,
  `role` VARCHAR(30) NOT NULL,
  `model` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`AIprocessingid`),
  INDEX `fk_payment_AIprocessings_payment_recording1_idx` (`recordingid` ASC) VISIBLE,
  INDEX `fk_payment_AIprocessings_payment_detectedcommands1_idx` (`detectedcommandsid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_AIprocessings_payment_recording1`
    FOREIGN KEY (`recordingid`)
    REFERENCES `paymentdb`.`payment_recording` (`recordingid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_AIprocessings_payment_detectedcommands1`
    FOREIGN KEY (`detectedcommandsid`)
    REFERENCES `paymentdb`.`payment_detectedcommands` (`detectedcommandsid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_voicecommands`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_voicecommands` (
  `voicecommandid` INT NOT NULL AUTO_INCREMENT,
  `status` TINYINT NOT NULL DEFAULT 0,
  `transcription` MEDIUMTEXT NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `mediafileid` INT NOT NULL,
  `AIprocessingid` INT NOT NULL,
  PRIMARY KEY (`voicecommandid`),
  INDEX `fk_payment_voicecommands_payment_mediafiles1_idx` (`mediafileid` ASC) VISIBLE,
  INDEX `fk_payment_voicecommands_payment_AIprocessings1_idx` (`AIprocessingid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_voicecommands_payment_mediafiles1`
    FOREIGN KEY (`mediafileid`)
    REFERENCES `paymentdb`.`payment_mediafiles` (`mediafileid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_voicecommands_payment_AIprocessings1`
    FOREIGN KEY (`AIprocessingid`)
    REFERENCES `paymentdb`.`payment_AIprocessings` (`AIprocessingid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_infotypecompany`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_infotypecompany` (
  `infotypecompanyid` INT NOT NULL AUTO_INCREMENT,
  `userinfotypesid` INT NOT NULL,
  `companyid` INT NOT NULL,
  PRIMARY KEY (`infotypecompanyid`, `userinfotypesid`, `companyid`),
  INDEX `fk_payment_userinfotypes_has_payment_company_payment_compan_idx` (`companyid` ASC) VISIBLE,
  INDEX `fk_payment_userinfotypes_has_payment_company_payment_userin_idx` (`userinfotypesid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_userinfotypes_has_payment_company_payment_userinfo1`
    FOREIGN KEY (`userinfotypesid`)
    REFERENCES `paymentdb`.`payment_userinfotypes` (`userinfotypesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_userinfotypes_has_payment_company_payment_company1`
    FOREIGN KEY (`companyid`)
    REFERENCES `paymentdb`.`payment_company` (`companyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_availablemethods`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_availablemethods` (
  `availablemethodid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `token` VARBINARY(128) NOT NULL,
  `exptokendate` DATETIME NOT NULL DEFAULT NOW(),
  `maskaccount` VARCHAR(20) NOT NULL,
  `userid` INT NOT NULL,
  `methodid` INT NOT NULL,
  PRIMARY KEY (`availablemethodid`),
  INDEX `fk_payment_availablemethods_payment_users1_idx` (`userid` ASC) VISIBLE,
  INDEX `fk_payment_availablemethods_payment_paymentmethods1_idx` (`methodid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_availablemethods_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_availablemethods_payment_paymentmethods1`
    FOREIGN KEY (`methodid`)
    REFERENCES `paymentdb`.`payment_paymentmethods` (`methodid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_payment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_payment` (
  `paymentid` BIGINT NOT NULL AUTO_INCREMENT,
  `amount` BIGINT NOT NULL,
  `actualamount` BIGINT NOT NULL,
  `result` TINYINT NOT NULL,
  `reference` VARCHAR(100) NOT NULL,
  `auth` VARCHAR(60) NOT NULL,
  `chargetoken` VARBINARY(128) NOT NULL,
  `description` VARCHAR(120) NULL,
  `error` VARCHAR(120) NULL,
  `date` DATETIME NOT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `moduleid` TINYINT(8) NOT NULL,
  `methodid` INT NOT NULL,
  `availablemethodid` INT NOT NULL,
  `userid` INT NOT NULL,
  PRIMARY KEY (`paymentid`),
  INDEX `fk_payment_payment_payment_modules1_idx` (`moduleid` ASC) VISIBLE,
  INDEX `fk_payment_payment_payment_paymentmethods1_idx` (`methodid` ASC) VISIBLE,
  INDEX `fk_payment_payment_payment_availablemethods1_idx` (`availablemethodid` ASC) VISIBLE,
  INDEX `fk_payment_payment_payment_users1_idx` (`userid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_payment_payment_modules1`
    FOREIGN KEY (`moduleid`)
    REFERENCES `paymentdb`.`payment_modules` (`moduleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_payment_payment_paymentmethods1`
    FOREIGN KEY (`methodid`)
    REFERENCES `paymentdb`.`payment_paymentmethods` (`methodid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_payment_payment_availablemethods1`
    FOREIGN KEY (`availablemethodid`)
    REFERENCES `paymentdb`.`payment_availablemethods` (`availablemethodid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_payment_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_transtypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_transtypes` (
  `transtypeid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`transtypeid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_transsubtypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_transsubtypes` (
  `transsubtypesid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`transsubtypesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_exchangerate`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_exchangerate` (
  `exchangerateid` INT NOT NULL AUTO_INCREMENT,
  `startdate` DATETIME NOT NULL DEFAULT NOW(),
  `enddate` DATETIME NOT NULL DEFAULT NOW(),
  `exchangerate` DECIMAL(15,8) NOT NULL,
  `enabled` BIT NOT NULL DEFAULT 0,
  `currentexchangerate` BIT NOT NULL DEFAULT 0,
  `sourcecurrencyid` INT NOT NULL,
  `destinycurrencyid` INT NOT NULL,
  PRIMARY KEY (`exchangerateid`),
  INDEX `fk_payment_exchangerate_payment_currency1_idx` (`sourcecurrencyid` ASC) VISIBLE,
  INDEX `fk_payment_exchangerate_payment_currency2_idx` (`destinycurrencyid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_exchangerate_payment_currency1`
    FOREIGN KEY (`sourcecurrencyid`)
    REFERENCES `paymentdb`.`payment_currency` (`currencyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_exchangerate_payment_currency2`
    FOREIGN KEY (`destinycurrencyid`)
    REFERENCES `paymentdb`.`payment_currency` (`currencyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_schedules`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_schedules` (
  `scheduleid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `recurrencytype` ENUM("Daily", "Weekly", "Monthly", "Annually") NOT NULL,
  `endtype` ENUM("Date", "Event") NOT NULL,
  `repetitions` INT NULL,
  `enddate` DATETIME NOT NULL,
  PRIMARY KEY (`scheduleid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_transactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_transactions` (
  `transactionid` INT NOT NULL AUTO_INCREMENT,
  `amount` BIGINT NOT NULL,
  `description` VARCHAR(120) NULL,
  `date` DATETIME NOT NULL DEFAULT NOW(),
  `posttime` DATETIME NOT NULL DEFAULT NOW(),
  `reference1` BIGINT NOT NULL,
  `reference2` BIGINT NOT NULL,
  `value1` VARCHAR(100) NOT NULL,
  `value2` VARCHAR(100) NOT NULL,
  `processmanagerid` INT NOT NULL,
  `convertedamount` BIGINT NOT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `transtypeid` INT NOT NULL,
  `transsubtypesid` INT NOT NULL,
  `paymentid` BIGINT NULL,
  `currencyid` INT NOT NULL,
  `exchangerateid` INT NOT NULL,
  `scheduleid` INT NULL,
  PRIMARY KEY (`transactionid`),
  INDEX `fk_payment_transactions_payment_transtypes1_idx` (`transtypeid` ASC) VISIBLE,
  INDEX `fk_payment_transactions_payment_transsubtypes1_idx` (`transsubtypesid` ASC) VISIBLE,
  INDEX `fk_payment_transactions_payment_payment1_idx` (`paymentid` ASC) VISIBLE,
  INDEX `fk_payment_transactions_payment_currency1_idx` (`currencyid` ASC) VISIBLE,
  INDEX `fk_payment_transactions_payment_exchangerate1_idx` (`exchangerateid` ASC) VISIBLE,
  INDEX `fk_payment_transactions_payment_schedules1_idx` (`scheduleid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_transactions_payment_transtypes1`
    FOREIGN KEY (`transtypeid`)
    REFERENCES `paymentdb`.`payment_transtypes` (`transtypeid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_transactions_payment_transsubtypes1`
    FOREIGN KEY (`transsubtypesid`)
    REFERENCES `paymentdb`.`payment_transsubtypes` (`transsubtypesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_transactions_payment_payment1`
    FOREIGN KEY (`paymentid`)
    REFERENCES `paymentdb`.`payment_payment` (`paymentid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_transactions_payment_currency1`
    FOREIGN KEY (`currencyid`)
    REFERENCES `paymentdb`.`payment_currency` (`currencyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_transactions_payment_exchangerate1`
    FOREIGN KEY (`exchangerateid`)
    REFERENCES `paymentdb`.`payment_exchangerate` (`exchangerateid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_transactions_payment_schedules1`
    FOREIGN KEY (`scheduleid`)
    REFERENCES `paymentdb`.`payment_schedules` (`scheduleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_scheduledetails`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_scheduledetails` (
  `scheduledetailsid` INT NOT NULL AUTO_INCREMENT,
  `deleted` BIT NOT NULL DEFAULT 0,
  `basedate` DATETIME NOT NULL,
  `datepart` VARCHAR(20) NOT NULL,
  `lastexcecution` DATETIME NOT NULL DEFAULT NOW(),
  `nextexcecution` DATETIME NOT NULL DEFAULT NOW(),
  `scheduleid` INT NOT NULL,
  PRIMARY KEY (`scheduledetailsid`),
  INDEX `fk_payment_scheduledetails_payment_schedules1_idx` (`scheduleid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_scheduledetails_payment_schedules1`
    FOREIGN KEY (`scheduleid`)
    REFERENCES `paymentdb`.`payment_schedules` (`scheduleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_subscriptions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_subscriptions` (
  `subscriptionid` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(120) NOT NULL,
  `logourl` VARCHAR(225) NOT NULL,
  PRIMARY KEY (`subscriptionid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_planprices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_planprices` (
  `planpricesid` INT NOT NULL AUTO_INCREMENT,
  `amount` BIGINT NOT NULL,
  `recurrencytype` TINYINT NOT NULL,
  `posttime` DATETIME NOT NULL DEFAULT NOW(),
  `endate` DATETIME NOT NULL DEFAULT NOW(),
  `current` BIT NOT NULL DEFAULT 0,
  `currencyid` INT NOT NULL,
  `subscriptionid` INT NOT NULL,
  PRIMARY KEY (`planpricesid`),
  INDEX `fk_payment_planprices_payment_currency1_idx` (`currencyid` ASC) VISIBLE,
  INDEX `fk_payment_planprices_payment_subscriptions1_idx` (`subscriptionid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_planprices_payment_currency1`
    FOREIGN KEY (`currencyid`)
    REFERENCES `paymentdb`.`payment_currency` (`currencyid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_planprices_payment_subscriptions1`
    FOREIGN KEY (`subscriptionid`)
    REFERENCES `paymentdb`.`payment_subscriptions` (`subscriptionid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_planperson`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_planperson` (
  `planpersonid` INT NOT NULL AUTO_INCREMENT,
  `acquisition` DATETIME NOT NULL DEFAULT NOW(),
  `enabled` BIT NOT NULL DEFAULT 0,
  `scheduleid` INT NOT NULL,
  `planpricesid` INT NOT NULL,
  `userid` INT NOT NULL,
  `expirationdate` DATE NOT NULL,
  PRIMARY KEY (`planpersonid`),
  INDEX `fk_payment_planperson_payment_schedules1_idx` (`scheduleid` ASC) VISIBLE,
  INDEX `fk_payment_planperson_payment_planprices1_idx` (`planpricesid` ASC) VISIBLE,
  INDEX `fk_payment_planperson_payment_users1_idx` (`userid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_planperson_payment_schedules1`
    FOREIGN KEY (`scheduleid`)
    REFERENCES `paymentdb`.`payment_schedules` (`scheduleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_planperson_payment_planprices1`
    FOREIGN KEY (`planpricesid`)
    REFERENCES `paymentdb`.`payment_planprices` (`planpricesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_planperson_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_planfeatures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_planfeatures` (
  `planfeaturesid` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(120) NOT NULL,
  `enabled` BIT NOT NULL DEFAULT 0,
  `datatype` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`planfeaturesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_featuresperplan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_featuresperplan` (
  `featuresperplanid` INT NOT NULL AUTO_INCREMENT,
  `value` VARCHAR(45) NOT NULL,
  `enabled` BIT NOT NULL DEFAULT 0,
  `subscriptionid` INT NOT NULL,
  `planfeaturesid` INT NOT NULL,
  PRIMARY KEY (`featuresperplanid`, `subscriptionid`),
  INDEX `fk_payment_featuresperplan_payment_subscriptions1_idx` (`subscriptionid` ASC) VISIBLE,
  INDEX `fk_payment_featuresperplan_payment_planfeatures1_idx` (`planfeaturesid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_featuresperplan_payment_subscriptions1`
    FOREIGN KEY (`subscriptionid`)
    REFERENCES `paymentdb`.`payment_subscriptions` (`subscriptionid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_featuresperplan_payment_planfeatures1`
    FOREIGN KEY (`planfeaturesid`)
    REFERENCES `paymentdb`.`payment_planfeatures` (`planfeaturesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_personplanlimits`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_personplanlimits` (
  `personplanlimitsid` INT NOT NULL AUTO_INCREMENT,
  `limit` TINYINT NOT NULL,
  `planpersonid` INT NOT NULL,
  `planfeaturesid` INT NOT NULL,
  PRIMARY KEY (`personplanlimitsid`),
  INDEX `fk_payment_personplanlimits_payment_planperson1_idx` (`planpersonid` ASC) VISIBLE,
  INDEX `fk_payment_personplanlimits_payment_planfeatures1_idx` (`planfeaturesid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_personplanlimits_payment_planperson1`
    FOREIGN KEY (`planpersonid`)
    REFERENCES `paymentdb`.`payment_planperson` (`planpersonid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_personplanlimits_payment_planfeatures1`
    FOREIGN KEY (`planfeaturesid`)
    REFERENCES `paymentdb`.`payment_planfeatures` (`planfeaturesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_logtypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_logtypes` (
  `logtypesid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `ref1description` VARCHAR(120) NOT NULL,
  `ref2description` VARCHAR(120) NOT NULL,
  `val1description` VARCHAR(120) NOT NULL,
  `val2description` VARCHAR(120) NOT NULL,
  `payment_logtypescol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`logtypesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_logsources`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_logsources` (
  `logsourcesid` INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`logsourcesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_logseverity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_logseverity` (
  `logseverityid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`logseverityid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_logs` (
  `logsid` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(120) NOT NULL,
  `posttime` DATETIME NOT NULL DEFAULT NOW(),
  `computer` VARCHAR(45) NOT NULL,
  `username` VARCHAR(50) NOT NULL,
  `trace` VARCHAR(100) NOT NULL,
  `referenceid1` BIGINT NULL,
  `referenceid2` BIGINT NULL,
  `value1` INT NULL,
  `value2` INT NULL,
  `checksum` VARBINARY(250) NOT NULL,
  `logtypesid` INT NOT NULL,
  `logsourcesid` INT NOT NULL,
  `logseverityid` INT NOT NULL,
  PRIMARY KEY (`logsid`),
  INDEX `fk_payment_logs_payment_logtypes1_idx` (`logtypesid` ASC) VISIBLE,
  INDEX `fk_payment_logs_payment_logsources1_idx` (`logsourcesid` ASC) VISIBLE,
  INDEX `fk_payment_logs_payment_logseverity1_idx` (`logseverityid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_logs_payment_logtypes1`
    FOREIGN KEY (`logtypesid`)
    REFERENCES `paymentdb`.`payment_logtypes` (`logtypesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_logs_payment_logsources1`
    FOREIGN KEY (`logsourcesid`)
    REFERENCES `paymentdb`.`payment_logsources` (`logsourcesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_logs_payment_logseverity1`
    FOREIGN KEY (`logseverityid`)
    REFERENCES `paymentdb`.`payment_logseverity` (`logseverityid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_languages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_languages` (
  `languagesid` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `culture` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`languagesid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_translation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_translation` (
  `translationid` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(20) NOT NULL,
  `caption` TEXT NOT NULL,
  `enabled` BIT NULL DEFAULT 1,
  `languagesid` INT NOT NULL,
  `moduleid` TINYINT(8) NOT NULL,
  PRIMARY KEY (`translationid`),
  INDEX `fk_payment_translation_payment_languages1_idx` (`languagesid` ASC) VISIBLE,
  INDEX `fk_payment_translation_payment_modules1_idx` (`moduleid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_translation_payment_languages1`
    FOREIGN KEY (`languagesid`)
    REFERENCES `paymentdb`.`payment_languages` (`languagesid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_translation_payment_modules1`
    FOREIGN KEY (`moduleid`)
    REFERENCES `paymentdb`.`payment_modules` (`moduleid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_humanAIinteractions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_humanAIinteractions` (
  `humanAIinteractionsid` INT NOT NULL AUTO_INCREMENT,
  `interactiontype` VARCHAR(20) NOT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT NOW(),
  `input` TINYINT NOT NULL,
  `output` TINYINT NOT NULL,
  `feedback` VARCHAR(100) NULL,
  `userid` INT NOT NULL,
  `detectedcommandsid` INT NOT NULL,
  `languagecode` VARCHAR(10) NULL,
  `voicename` VARCHAR(25) NULL,
  `ssmlgender` VARCHAR(10) NULL,
  `audioencoding` VARCHAR(10) NULL,
  `audiopath` VARCHAR(300) NULL,
  PRIMARY KEY (`humanAIinteractionsid`),
  INDEX `fk_payment_humanAIinteractions_payment_users1_idx` (`userid` ASC) VISIBLE,
  INDEX `fk_payment_humanAIinteractions_payment_detectedcommands1_idx` (`detectedcommandsid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_humanAIinteractions_payment_users1`
    FOREIGN KEY (`userid`)
    REFERENCES `paymentdb`.`payment_users` (`userid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_humanAIinteractions_payment_detectedcommands1`
    FOREIGN KEY (`detectedcommandsid`)
    REFERENCES `paymentdb`.`payment_detectedcommands` (`detectedcommandsid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_AIanalysisresults`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_AIanalysisresults` (
  `AIanalysisresultsid` INT NOT NULL AUTO_INCREMENT,
  `analysistype` VARCHAR(40) NOT NULL,
  `resultdata` JSON NOT NULL,
  `confidencescore` TINYINT NOT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT NOW(),
  `AIprocessingid` INT NOT NULL,
  `language` VARCHAR(10) NOT NULL,
  `text` TINYTEXT NOT NULL,
  `model` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`AIanalysisresultsid`),
  INDEX `fk_payment_AIanalysisresults_payment_AIprocessings1_idx` (`AIprocessingid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_AIanalysisresults_payment_AIprocessings1`
    FOREIGN KEY (`AIprocessingid`)
    REFERENCES `paymentdb`.`payment_AIprocessings` (`AIprocessingid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_systemaction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_systemaction` (
  `systemactionid` INT NOT NULL AUTO_INCREMENT,
  `actiontype` VARCHAR(30) NOT NULL,
  `executiontime` DATETIME NOT NULL DEFAULT NOW(),
  `status` ENUM("Failed", "Successful") NOT NULL,
  `details` VARCHAR(200) NOT NULL,
  `detectedcommandsid` INT NOT NULL,
  `transactionid` INT NULL,
  PRIMARY KEY (`systemactionid`),
  INDEX `fk_payment_systemaction_payment_detectedcommands1_idx` (`detectedcommandsid` ASC) VISIBLE,
  INDEX `fk_payment_systemaction_payment_transactions1_idx` (`transactionid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_systemaction_payment_detectedcommands1`
    FOREIGN KEY (`detectedcommandsid`)
    REFERENCES `paymentdb`.`payment_detectedcommands` (`detectedcommandsid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_systemaction_payment_transactions1`
    FOREIGN KEY (`transactionid`)
    REFERENCES `paymentdb`.`payment_transactions` (`transactionid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `paymentdb`.`payment_writtencommands`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `paymentdb`.`payment_writtencommands` (
  `writtencommandsid` INT NOT NULL AUTO_INCREMENT,
  `sessionid` VARCHAR(45) NOT NULL,
  `input` TEXT NOT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT NOW(),
  `source` VARCHAR(25) NOT NULL,
  `context` JSON NULL,
  `AIprocessingid` INT NOT NULL,
  `humanAIinteractionsid` INT NOT NULL,
  PRIMARY KEY (`writtencommandsid`),
  INDEX `fk_payment_writtencommands_payment_AIprocessings1_idx` (`AIprocessingid` ASC) VISIBLE,
  INDEX `fk_payment_writtencommands_payment_humanAIinteractions1_idx` (`humanAIinteractionsid` ASC) VISIBLE,
  CONSTRAINT `fk_payment_writtencommands_payment_AIprocessings1`
    FOREIGN KEY (`AIprocessingid`)
    REFERENCES `paymentdb`.`payment_AIprocessings` (`AIprocessingid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_writtencommands_payment_humanAIinteractions1`
    FOREIGN KEY (`humanAIinteractionsid`)
    REFERENCES `paymentdb`.`payment_humanAIinteractions` (`humanAIinteractionsid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
