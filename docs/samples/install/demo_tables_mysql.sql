CREATE TABLE `customers` (
  `customerID` int(10) unsigned NOT NULL auto_increment,
  `firstName` varchar(100) NOT NULL,
  `lastName` varchar(100) NOT NULL,
  `email` varchar(250) NOT NULL,
  `city` varchar(45) NOT NULL,
  `state` varchar(45) NOT NULL,
  `phone` varchar(45) NOT NULL,
  PRIMARY KEY  (`customerID`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=latin1;

CREATE TABLE `orders` (
  `orderID` int(10) unsigned NOT NULL auto_increment,
  `orderDate` datetime NOT NULL,
  `customerName` varchar(250) NOT NULL,
  `customerID` int(10) unsigned NOT NULL,
  `subtotal` float NOT NULL,
  `shipping` float NOT NULL,
  `tax` float NOT NULL,
  `total` float NOT NULL,
  `paymentMethod` varchar(45) NOT NULL,
  `shipmentMethod` varchar(45) NOT NULL,
  `trackingNo` varchar(45) NOT NULL,
  `shipToCity` varchar(45) NOT NULL,
  `shipToState` varchar(45) NOT NULL,
  `billToCity` varchar(45) NOT NULL,
  `billToState` varchar(45) NOT NULL,
  PRIMARY KEY  (`orderID`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=latin1;

