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
