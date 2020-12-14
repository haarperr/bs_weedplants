CREATE TABLE `weed_plants` (
  `id` int(11) NOT NULL,
  `properties` text NOT NULL,
  `plantid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `weed_plants`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `weed_plants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES 
('weed_bananakush', 'Banana Kush 2G', 1, 0, 1),
('weed_bluedream', 'Blue Dream 2G', 1, 0, 1),
('weed_purplehaze', 'Purple Haze 2G', 1, 0, 1),
('weed_og-kush', 'OGKush 2G', 1, 0, 1),
('weed_og-kush_seed', 'OGKush Seed', 1, 0, 1),
('weed_bananakush_seed', 'Banana Kush Seed', 1, 0, 1),
('weed_bluedream_seed', 'Blue Dream 2G', 1, 0, 1),
('weed_purple-haze_seed', 'Purple Haze 2G', 1, 0, 1),
('water_bottle', 'Water Bottle', 1, 0, 1),
('fertilizer', 'Fertilizer', 1, 0, 1);


