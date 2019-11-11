

# Administration Base de donné

---

Nous allons manipuler un jeu de donné, on travaillera sur une machine virtuel de Debian10 via SSH depuis macOS. 

## Description du jeu de données

Le jeux de donné choisit est a télécharger sur http://www.nosdonnees.fr/dataset/liste-des-jardins-publics-de-france, Il decrit les différents jardin de la ville de Nantes,leur nom, leur surface, leur adresse, les transport qui passe par ceux-ci, la presence de de gardien, de jeux, de pategeoire, de sanitaire, de jardin clos, d'abri, de point d'eau, de table de pic-nic, de sanitaire handicapé, si les chien son interdit ou non et un  commentaire concernant le placement du parc.

---

## Instalation de mysql

Pour commencer : 

```shell
apt-get update && apt-get upgrade 
```

```shell
apt-get install libaio1 libtinfo5
```

```shell
cd /usr/local
```

On va télécharger le fichier compresser de mysql dans notre dossier /usr/ocal

```shell
wget https://dev.mysql.com/get/Downloads/MySQL-8.0.17/mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz
```

On le décompresse :

```shell
tar xvf mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz
```

On créer un liens symboliques pour par avoir à taper tout le nom à chaque fois 

```shell
ln -s mysql-8.0.17-linux-glibc2.12-x86_64.tar.xz mysql
```

```shell
cd mysql
```

---

## Import du jeu de données

Dans le dossier mysql-dump : 

```shell
wget http://www.nosdonnees.fr/dataset/1f7528e2-7cc9-41f8-a27b-d159b39138f1/resource/37c8e254-061a-4e3b-949c-cab2d11008af/download/listejardinspublicsnantes.xls
```

Le fichier choisit est un fichier xls, on va le convertir en Csv avec csvkit :

```shell
apt install csvkit
```

```shell
in2csv listejardinspublicsnantes.xls > jardinsnantes.csv
```

```shell
apt purge csvkit
```

```sql
CREATE DATABASE jardins;
```

```mysql
CREATE TABLE jardins (
	Nom VARCHAR (100),
	Surface INT,
	Adresse Varchar (100),
	Transport Varchar (100),
  Gardien Varchar(3),
  Jeux Varchar(3),
  Pataugeoire Varchar(3),
  Sanitaires Varchar(3),
  ChienInterdit Varchar(3),
  JardinsClos Varchar(3),
  Abris Varchar(3),
  Eau Varchar(3),
  TablePicNic Varchar(3),
  SanitaireHandicap Varchar(3),
  Commentaire TEXT
)
```



```sql
LOAD DATA INFILE '/usr/local/mysql-G1-master/mysql-dumps/jardinsnantes.csv' INTO TABLE jardins FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
```

---

## Trigger

On crée un trigger qui verifira si une entré dans la colonne commentaire fait bien un minimum de 40 caractère 

```sql
DELIMITER ||

DROP TRIGGER IF EXISTS min_comment_lenth;

CREATE TRIGGER min_comment_lenth
BEFORE INSERT ON jardins
FOR EACH ROW
BEGIN
    IF LENGTH(NEW.Commentaire) < 40
    THEN
        SIGNAL SQLSTATE '12500' SET MESSAGE_TEXT = "Vous devez entrez un comentaire contenant d'autre inforations sur le parc";
    END IF;
END ||

DELIMITER ;
```

Test de du trigger : 

![](/Users/julienbonnanfant/Desktop/Capture d’écran 2019-11-11 à 17.12.55.png)

---

## Procedure

Création d'une procedure qui recupère les parcs qui contiennent des toilettes :

```sql
DELIMITER ||

CREATE PROCEDURE get_park_with_toilette ()
BEGIN
    SELECT NOM 
    	FROM jardins WHERE Sanitaires
    	LIKE "Oui";
END ||

DELIMITER ;
```

Test de cette procédure : 

![](/Users/julienbonnanfant/Desktop/Capture d’écran 2019-11-11 à 17.19.51.png)

Création d'une procédure qui trouve les parks avec point d'eau : 

```sql
DELIMITER ||

CREATE PROCEDURE get_park_with_water ()
BEGIN
    SELECT NOM 
    	FROM jardins WHERE Eau
    	LIKE "Oui";
END ||

DELIMITER ;
```

Test de la procédure : 

![](/Users/julienbonnanfant/Desktop/Capture d’écran 2019-11-11 à 17.25.15.png)







## Dump de la Base de donné



```sql
bin/mysqldump -u root -p --databases "db" --tables "table" --routines > fichier.sql
```



```sql
-- MySQL dump 10.13  Distrib 8.0.17, for linux-glibc2.12 (x86_64)
--
-- Host: localhost    Database: jardins
-- ------------------------------------------------------
-- Server version	8.0.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `jardins`
--

DROP TABLE IF EXISTS `jardins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jardins` (
  `Nom` varchar(100) DEFAULT NULL,
  `Surface` int(11) DEFAULT NULL,
  `Adresse` varchar(100) DEFAULT NULL,
  `Transport` varchar(100) DEFAULT NULL,
  `Gardien` varchar(3) DEFAULT NULL,
  `Jeux` varchar(3) DEFAULT NULL,
  `Pataugeoire` varchar(3) DEFAULT NULL,
  `Sanitaires` varchar(3) DEFAULT NULL,
  `ChienInterdit` varchar(3) DEFAULT NULL,
  `JardinsClos` varchar(3) DEFAULT NULL,
  `Abris` varchar(3) DEFAULT NULL,
  `Eau` varchar(3) DEFAULT NULL,
  `TablePicNic` varchar(3) DEFAULT NULL,
  `SanitaireHandicap` varchar(3) DEFAULT NULL,
  `Commentaire` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jardins`
--

LOCK TABLES `jardins` WRITE;
/*!40000 ALTER TABLE `jardins` DISABLE KEYS */;
INSERT INTO `jardins` VALUES ('Jardin Confluent',28040,'Rue Dos d\'Ane','Pirmil Lignes 2 3','non','non','non','non','non','non','non','non','non','non',''),('Parc des Dervallières',82110,'Rue Louis Le Nain','Vincent Auriol Ligne 56','non','non','non','non','non','non','non','non','non','oui','Bordé par la vallée de la Chézine, le boulevard du Massacre et les batiments de la cité des Dervallières, le parc offre de nombreuses activités de plein air. La création des jardins à thémes avec différents usages jouxtent la rue Renoir. La transformation de la pièce d\'eau sera le premier élément de transformation de la zone avec notamment l\'installation d\'un ponton pour faire naviguer les modèles réduits, la plantation de végétaux avec l\'idée de créer une ambiance de tableau impressionnistes. Le long du sentier vers les vestiges du chateau, on trouvera le jardin des roses et le jardin des rencontres.'),('Jardin d\'enfants de Procé',5800,'Rue des Dervallières','Lignes 22 et 56 - Procé','oui','oui','oui','oui','oui','oui','non','oui','non','non','D\'une superficie de 5800 m2, le petit jardin de Procé jouxte le parc du même nom. Véritable lieu de détente, ce square est pourvu de jeux pour les enfants et d\'une pataugeoire, mise en eau pour la période estivale, dont la margelle provient du bassin qui était situé place de la duchesse Anne. Ce dernier avait été démonté en 1929, afin de permettre la mise en œuvre du chantier du tunnel Saint-Félix (devant passer sous la place et les cours Saint-Pierre et Saint-André) afin de détourner le cours de l’Erdre.'),('PARC DE PROCE',113000,'Rue des Dervallières, Boulevard des Anglais','Lignes 22 et 56 - Procé','oui','oui','non','oui','non','oui','non','oui','non','oui',''),('Square Amiral Halgand',1298,'PLACE DE L\'HOTEL DE VILLE','Hôtel de ville Lignes 11 12 21 22 23 C LU','non','non','non','oui','non','oui','non','non','non','non','Le square de la Mairie date de la reconstruction d\'après-guerre, quelques jeux et la statue du Général Leclerc sont les principaux ornements.'),('JARDIN DES PLANTES',73280,'PLACE CHARLES LEROUX','Gare SNCF Lignes 1 et 12','oui','oui','oui','oui','non','oui','oui','oui','non','oui',''),('Cours Cambrone',8762,'RUE DES CADENIERS','Graslin Ligne 11','non','non','non','oui','non','oui','non','non','non','non','Le cours planté de très beau Magnolia grandiflora, orné de boulingrins et de massifs fleuris ainsi que de la statue du Général Cambronne assure la liaison entre la Place Graslin et les Quais de la Fosse.'),('Square Louis Bureau',1947,'PLACE DE LA MONNAIE','Jean V Ligne 11','non','oui','non','oui','non','oui','non','oui','non','oui','Espace vert d\'accès au Muséum d\'histoire naturelle, ce square orné d\'un boulingrin et de beaux arbres devrait évoluer progressivement en salle d\'animation extérieure pour le Muséum.'),('SQUARE ILE DE VERSAILLES',15000,'Quai de Versailles','Saint Mihiel Ligne 2','non','oui','non','oui','non','oui','oui','oui','non','oui','L\'Ile a été réalisée avec des matériaux de dragage lors du creusement du canal de Nantes à Brest puis a été occupée par des activités artisanales diverses liées à la rivière.\n\nC\'est à partir de 86, après que la Ville ait terminé l\'acquisition des dernières parcelles que les travaux d\'aménagement commencèrent.\n\nA l\'issue du concours d\'architectes, c\'est l\'équipe Dulieu, complétée par le Paysagiste Soulard, qui obtint le chantier avec une réalisation sur le thème japonais. Inauguration : septembre 87.\n\nLa composition s\'articule autour de 3 constructions. La Capitainerie (destinée à gérer les activités du port de l\'Erdre). La Maison de l\'Erdre (sa structure carrée entoure un jardin zen ). Elle est utilisée par de nombreuses expositions ayant le thème de l\'Erdre et de l\'environnement aquatique. Et pour terminer, le restaurant situé à l\'extrémité de l\'Ile.\n\nLe paysage recréé et structuré par des rocailles, cascades et pièces d\'eau est richement planté de végétaux exotiques tels que bambous, cyprès chauves, rhododendrons, camellias et cerisiers japonais.'),('Square Maquis de Saffré',3000,'Quai Ceineray','Bonde 22','non','non','non','non','non','non','non','non','non','oui','Les abords de l\'entrée du tunnel de détournement de l\'Erdre ont été aménagés dans les années 1930. L\'actuel square du Maquis de Saffré, en prolongement du Cours Saint André, fait face aux tables mémoriales de la guerre de 1914 1918. Le jardin commence même avant sa clôture. De larges gradins descendent entre deux rangées d\'érables boules jusqu\'au quai de la rivière. Le travail du granit poursuit celui des emmarchements du Cours Saint André. En ne plantant pas des arbres à grand développement, l\'architecte, Etienne Coutan (1875-1963), a préservé la vue sur l\'Erdre. Le quai en contrebas a lui aussi été traité : visibles depuis le quai Ceyneray, des palntations le long du mur suivent le rytme des arbres du square.\n\nLa statue de la Délivrance qui avait été installée en 1927 devant les tables mémoriales puis déboulonnée par des individus offusqués par sa nudité, fut rétablie en 1937, cette fois sur le socle qui se trouve toujours dans le bas du square. A nouveau decendue en 1940, elle siège depuis 1987 devant l\'Hôtel de la Région à la pointe de l\'Ile Beaulieu.'),('Square Jean-Batiste Daviais',2965,'PLACE DE LA PETITE HOLLANDE','Commerce Lignes 11 32 51 52 54 CDB','non','non','non','non','non','oui','non','non','non','non','Ou square de la Petite Hollande\n\nConçu par Etienne Coutant, cet espace situé en proue de l\'île Feydeau, a été aménagé après les comblements de Loire. Un bassin et quelques plantations viennent agrémenter le site.\n\n\n\nDans les années 1930, les comblements de la Loire sont l\'occasion de l\'aménagement de ce square sis la pointe ouest de l\'ancienne Ile Feydeau. Dans l\'axe du lit de l\'ancien bras de Loire, le jardin est tracé en creux pour le protéger des vents d\'ouest. Il est particulièrement destiné aux ébats des enfants autour d\'un bassin circulaire évoquant la mémoire de l\'eau. Du côté des immeubles de l\'ïle Feydeau, clôtures, escaliers, locaux de service sont traités avec des blocs de granit taillés. Les escaliers ouverts dans les axes de la composition dialoguent avec les rampes pratiquées dans les angles; A la livraison, une décision municipale en limita l\'accès \"aux dames et aux enfants\", c\'est pourquoi Coutan fit placer à l\'extérieur des bancs à l\'usage de ceux qui n\'y étaient pas admis...\n\nLe monument dédié aux résistant Jean-Baptiste Daviais fut installé après la dernière guerre.'),('JARDIN DES CINQ SENS',3000,'RUE CELESTIN FRENET ou RUE GAETAN RONDEAU','Rondeau Ligne 58','non','oui','non','oui','non','non','non','oui','non','oui','Le jardin des 5 Sens  avait été conçu comme un espace d\'accueil, sollicitant les 5 sens en privilégiant à travers le tracé, les équipements et les plantations.'),('Square Charles Housset',1100,'Rue Charles Housset','Janvraie 25 H 81','non','non','non','non','non','non','non','non','non','non','Situé au milieu d\'un carrefour, ce square est avant tout un espace vert d\'accompagnement de voirie.'),('Square Faustin Hélie',9441,'RUE FAUSTIN HELIE','Jean Jaures Ligne 3','non','oui','non','non','non','oui','non','non','non','non','Espace vert d\'accompagnement de l\'ancien Palais de justice, ce square bien planté offre des espaces de repos ombrés aux gens du quartier.'),('PARC DE LA BEAUJOIRE',133000,'Route de Saint Joseph','Roseraie     lignes 22 et 72','oui','oui','non','oui','non','oui','oui','oui','non','oui',''),('Parc du Plessis Tison',13940,'Rond Point de Paris rue de Racapé','Rond Point de Paris Ligne 70 LU','oui','oui','oui','oui','oui','oui','non','non','oui','oui','Le parc du Plessis Tison est fréquenté par les habitants du quartier. Il comporte une pataugeoire et des jeux d\'enfants. On peut y trouver de nombreuses espèces de chênes. Particularité de ce parc une montagne comparable bien que de moindre importance à celle du Jardin des plantes,'),('Square Maurice Schwob',7203,'Rue des Garennes','Gassendi Ligne 81','non','oui','non','oui','oui','oui','non','oui','non','non','Implanté au-dessus d\'un front rocheux important, ce square dessiné par Coutant au début du siècle domine la Loire et propose de fait, un point de vue intéressant sur le fleuve.\n\nEn 1932, Etienne Coutan envisage une promenade en corniche reliant les hauteurs de Miséry aux côteaux de l\'hermitage, lieu réputé des plus insalubres de Nantes et siège des premières expériences d\'habitat social.\n\nL\'emplacement du square est pittoresque, dominant la Loire et l\'ancienne carrière de granit. Le végétal est ici parfaitement maîtrisé et prend valeur d\'architecture ; le granit des murets de clôture et de soutènement renvoie à la nature du site, Le local de service, occupé jusqu\'au début des années 1990 par un gardien, se présente comme un belvédère. Le groupe sculpté par Paul Auban représente une mère bretonne éplorée, le corps de son fils rejeté par les flots étendu devant elle. Elle tend un poing vengeur vers le fleuve qu\'elle maudit. Cette statuaire identifie bien Chantenay et la Butte Ste Anne comme territoire breton. Le jardin a fait l\'objet d\'une réhabilitation au cour de l\'année 2011.'),('SQUARE ELISA MERCOEUR',27120,'COURS COMMANDANT ESTIENNE D\'ORVES','Bouffay Ligne 1 - Monteil Ligne 24 56 A','non','non','non','non','non','non','non','non','non','non','Square de  l\'après-guerre, il avait été conçu comme un jardin pour les enfants du centre ville. Il comportait un des premiers sequoias de chine introduit en Europe.'),('Square Marcel Launay',10300,'BOULEVARD GENERAL DEGAULE','Beaulieu Ligne 4','non','oui','non','non','non','non','non','non','non','non','Espace vert de promenade et de liaison à proximité du grand centre commercial de l\'Ile de Nantes'),('Square Jean Le Gigant',6430,'Rue Maurice Terrien','Cabrol Ligne 70','non','oui','oui','oui','non','oui','non','oui','non','non','Espace vert de quartier, ce square équipé d\'une pataugeoire et d\'un espace de jeux,  fait le bonheur des enfants aux beaux jours.'),('SQUARE TOUSSAINT LOUVERTURE',4737,'Rue des usines','Usine à gaz Ligne 81','non','oui','non','non','non','non','non','non','non','oui','La réalisation de ce square est récente. Un belvédère ouvre la vue sur la Loire et ses installations portuaires. Les végétaux sont à dominante méditerranéenne.'),('Parc des Capucins',8550,'Rue Noire','Poitou Ligne 3','non','oui','non','oui','non','oui','non','oui','non','oui','Ce parc d\'une superficie de 8500 m² a ouvert ses porte le 13 février 1993. Son entrée principale donne sur la rue Noire et il vient ainsi desservir un quartier fortement urbanisé, peu favorisé en espaces verts.\n\nCette propriété et ses batiments ont été construits par le Pères Capucins en 1874. En 1805 après la nationalisation des biens de l\'Eglise, ils partent en Hollande et reviennent après la guerre en 1918. Jusqu\'en 1960, on y apprend la théologie, puis on y reçoit les sans abris.\n\nEn 1982, il ne reste plus qu\'une dizaine de Capucins et la propriété est cédée à la Ville en 1985.\n\nLa partie bâtie accueille maintenant la compagnie de danse Brumahon ainsi qu\'un centre médico-social.\n\nLe parc est construit selon un ordonnancement classique avec un vaste carré de pelouse au centre, délimité de haies taillées à la manière d\'un cloître de plein air. Autour des arbres centenaires étalent leur frondaison au-dessus de la rue : séquoias, cèdres, chênes tauzins, cormiers…'),('PARC DE LA NOE MITRIE',17200,'BOULEVARD ERNEST DALBY','Mitrie Lignes 11 12 70','non','oui','oui','oui','oui','oui','non','oui','non','non','Un des jardins les mieux appréciés des enfants : deux grandes pataugeoires, de grandes aires de jeux, un bel espace arboré avec de très beaux arbres, cyprès chauve de Louisianne et plantes de terre de bruyère.'),('Square Jean-Baptiste Barre',1724,'RUE JEAN-BAPTISTE BARRE','Marcel Hatet Ligne 12','non','oui','non','non','oui','oui','non','non','non','non','Ce petit square situé dans le quartier Toutes Aides a été entièrement rénové en 1995, on y trouve une fontaine à l\'italienne ornée d\'un mascaron et d\'une petite aire de jeux.'),('Square Jules Bréchoir',2720,'RUE JULES BRECHOIR','Toutes Aides 58 A 75 82 92 - Bd de Doulon Ligne 1','non','non','non','non','oui','oui','non','non','non','oui','Petit jardin de proximité dans les anciens bains douche de Toutes Aides,'),('Parc de Malakoff',42260,'BOULEVARD DE SARREBRUCK','San Francisco Ligne 58 A','non','non','non','non','non','non','non','oui','non','oui','Même s\'il n\'a pas le prestige des grands parcs nantais, c\'est pour les habitants de la cité de Malakoff un formidable poumon vert. Dénommé également parc de Mauves, il a été créé au début des années 1980 sur la décharge municipale occupant une partie de l\'ancienne prairie de Mauves. Un peu plus grand que quatre terrains de football, son attrait principal était, il y a peu de temps encore, l\'immense pataugeoire en forme de lac. Mais des impératifs techniques et règlementaires ont contraint la mairie à la modifier avant de se résoudre à ne plus la mettre en service. Cela donne au parc de nouveaux atouts, une piste de skates et rollers toute trouvée, un petit toboggan et une grande pyramide de cordes haute de sept mètres que les enfants surnomment \"l\'araignée\". Dans ce parc on vient d\'abord chercher le calme, les plantations denses ont vite formé un écran le protégeant de la circulation automobile alentour mais aussi des regards ce qui explique qu\'il soit si peu connu.'),('Square Gustave Roch',3279,'BOULEVARD GUSTAVE ROCH','Wattignies Lignes 2 3','non','oui','non','non','non','oui','non','non','non','non','Petit square situé sur l\'Ile Sainte Anne, doté de quelques jeux pour enfants et d\'un espace de jeu de ballon.'),('Place Basse Mar',1124,'PLACE BASSE MAR','Pompidou 24 52 B','non','oui','oui','non','non','oui','non','non','non','oui','Situé à la pointe est de l\'île beaulieu, ce jardin est destiné aux jeunes enfants avec sa pataugeoire.'),('SQUARE VERTAIS',12320,'BOULEVARD DES MARTYRS NANTAIS DE LA RESISTANCE','Mangin 2 3 - Bourgault Ducou 42 B','non','oui','non','oui','non','non','non','oui','oui','oui','Situé sur l\'Ile Beaulieu, ce square de quartier a été réhabilité en 2001, On y trouve ainsi une aire de jeux protégée, quelques équipements sportifs et un petit groupe de jardins familiaux. Le viaduc SNCF confié au grapheur Boris Briand accueille une jungle luxuriante.'),('Square du Prinquiau',2650,'Rue du Prinquiau - Boulevard de l\'Egalité','Convention Lignes 11 70','non','oui','non','non','oui','oui','non','non','oui','oui','Petit espace vert de quartier, ce square va être inscrit dans un programme de réhabilitation pour les années à venir.'),('Square Canclaux',1634,'Place Canclaux','Canclaux Lignes 21 23 24 H','non','oui','non','non','non','non','non','non','non','oui','Ce square est en cours de restauration. Situé au centre d\'un immense giratoire, il assure à la fois des fonctions d\'espace public classique et d\'espace vert avec également des jeux pour petits.'),('Square des Combattants d\'Afrique du Nord',1811,'Rue Mathurin Brissoneau - Place René Bouhier','René Bouhier Ligne 11','non','oui','non','non','oui','oui','non','non','non','oui','Restauré en 1995, cet espace offre au quartier un espace de jeux pour jeunes enfants.'),('Square de l\'Edit de Nantes',737,'PLACE DE L\'EDIT DE NANTES','Edit de Nantes Lignes 21 23 24 56 H','non','oui','non','non','non','oui','non','oui','non','non','Réaménagé en 1996, ce petit square de quartier offre à la fois des jeux pour enfants et un espace jardiné pour les riverains.'),('Square Marcel Moisan',691,'Rue de l\'hermitage','Lechat Ligne 21 H','non','oui','non','non','oui','oui','non','non','non','non','Situé à proximité du Planétarium, ce square réhabilité en 1995 présente un cadran solaire \"le Scaphé de Bérose\" et des plantes sélectionnées dans la littérature de Jules Verne.'),('SQUARE PASCAL LEBEE',539,'PLACE NEWTON','Delorme Ligne 22 51 54 F','non','non','non','oui','non','non','non','non','non','non','Réaménagé en 1997, ce square a laissé la place à un aménagement ouvert favorisant les liaisons piétonnes dans le quartier.\n\nA noter la plantation de Pyrus \'Bradford\''),('Square Etienne Destranges',701,'Place Edouard Normand','Jean Jaures Ligne 3','non','non','non','non','non','non','non','non','non','non','Ce petit espace vert de 700 m2 situé près de l\'ancien Palais de Justice apporte un peu de fraîcheur dans ce secteur très minéralisé.'),('Centre social de la Pilotière',10830,'BOULEVARD JULES VERNE','Platane Ligne 23','non','oui','non','non','non','oui','non','non','non','non','Square de quartier avec jeux pour enfants et plantations'),('Square Augustin Fresnel',5600,'RUE AUGUSTIN FRESNEL','Fresnel Ligne 21','non','oui','non','non','non','non','non','non','non','oui','Petit espace de verdure entre la rue Louis Guiotton et la rue Auguste Fresnel'),('Parc de Broussais',12130,'Place Gabriel Trarieux','Toutes Aides Lignes 12 70','non','oui','non','non','non','non','non','non','non','oui','Il s\'agit du parc de l\'ancien hôpital militaire Broussais, aujourd\'hui occupé par des logements HLM. Il comporte de très beaux arbres (sequoiadendron, arbousier)'),('PARC DU GRAND-BLOTTEREAU',192660,'BOULEVARD AUGUSTE PENEAU','Tram ligne 1 ou bus lignes 12, 58,75, 82, 92','oui','oui','non','oui','non','oui','non','oui','non','oui',''),('Square Benoni Goulin',1979,'RUE DU SCORFF','MIN Ligne 52','non','non','non','non','non','non','non','non','non','non',''),('Square rue Jules Sebilleau',1820,'RUE JULES SEBILLEAU','Sebilleau Lignes 24 52 B','non','non','non','non','non','oui','non','non','non','non','Cet espace va être prochainement réaménagé en espace sportif et en espaces de jeux pour enfants.'),('Parc Say',8010,'RUE DESIRE COLOMBE','Sanitat Ligne 11','non','non','non','non','non','non','non','non','non','non','Ce petit parc actuellement sous utilisé du fait de son enclavement devrait pouvoir bénéficier prochainement d\'une ouverture sur les espaces publics de la ZAC située à proximité.'),('Square de la Marseillaise',1896,'Rue du Bois Hercé - Rue de la Marseillaise','Marseillaise Ligne 11','non','oui','non','non','non','non','non','non','non','non','Espace de transition inter quartier, ce square ouvert est équipé d\'un espace de jeux pour petits.'),('Square des Marthyrs Irlandais',10710,'Rue Francis Portais - Rue de l\'Adour','Romain Rolland Ligne 1','non','oui','non','non','non','oui','non','oui','non','oui','Situé dans l\'emprise d\'une ZAC, ce square fera prochainement l\'objet d\'une recomposition complète.'),('Square du Bois de la Musse',7902,'Rue Etienne Coutan','Bernanos Lignes 25 H 74','non','oui','non','non','non','non','non','non','non','non','Espace  de transition piétonne, cet espace vert est planté de vieux arbres qui lui donnent un caractère naturel au coeur d\'une cité d\'habitat social.'),('PARC DE LA BOUCARDIERE',26010,'Rue de l\'Abbaye - Chemin de la Petite Boucardière','Bois Hardy Lignes 25 81','non','oui','non','non','non','oui','non','oui','non','non','Aménagée sommairement, cette ancienne propriété privée est un espace vert de quartier pour la ballade et les jeux d\'enfants.'),('Square Gaston Michel',1788,'Boulevard des Américains','Americains 12 32 DLU','non','oui','non','non','oui','oui','non','non','non','non','Gaston Michel, conseiller municipal dans la municipalité Pageot de 1935, a donné son nom au square qui jouxte le boulevard des Américains. Ce square clos a fait l\'objet d\'une concertation en 2013 ou plusieurs aménagements ont complété les jeux existants pour le plus grand bonheur des enfants. La réalisation du terrain de basket, la mise en place de gazon et la plantation de nombreux arbustres confèrent à cet espace les fonctions d\'un véritable espace vert de quartier.  Square interdit aux chiens, pas de sanitaires.'),('Square Proust Bergson',1344,'Rue Marcel Proust - Rue Henri Bergson','Monge Chauviniere Ligne 96','non','non','non','non','non','non','non','non','non','non',''),('Parc du Petit Port',493800,'Boulevard des tribunes','Champ de courses 25 51 52','non','non','non','non','non','non','non','non','oui','non','Espace naturel intégré à l\'hippodrome du Petit Port'),('Parc de Beaulieu',12970,'Cours de la prairie d\'Amont','Hôtel de région 52 B','non','oui','non','non','non','non','oui','oui','oui','oui',''),('Aire de jeux des Renards',28030,'Rues Stéphane Leduc - de la Petite Sensive - de Rome - des Renards - Dorsay','Riviere Lignes 72 83 86','non','oui','non','non','non','oui','non','non','oui','non','Espace situé dans la continuité de la promenade des Renards'),('Square Gabriel Chéreau',938,'RUE D\'ANCIN','Médiathèque Ligne 1','non','oui','non','non','non','oui','non','oui','non','non','Réaménagé en 1995, ce square de quartier n\'est accessible que par l\'intérieur de la Médiathèque, En 2011, à la demande des habitants du quartier, une partie du square a été aménagée en jardin partagé : le papotager.'),('Square des Courtils',4198,'Rue des Courtils','Jean Mace Lignes 21 70','non','oui','non','non','non','non','non','non','non','oui','Situé dans le quartier Chantenay, le square des Courtils se trouve à l\'extrêmité de la rue du même nom. Historisquement, l\'idée d\'implantation du square est due à l\'opposition des habitants du quartier de voir ériger en 1989 un immeuble par un promoteur privé. \n\nLa forme de la surface gazonnée du square correspond d\'ailleurs à celle du batiment prévu initialement. La réhabilittion amorcée en 2009 avec un groupe d\'habitants a permis de consolider les aménagements existants ( pergola, aire de skate-board, aire de détente ) mais aussi d\'implanter plusieurs jeux pour les petits.'),('CIMETIERE PARC',71937,'Rond-point Jean Moulin','Ligne 32 Bout des Landes','oui','non','non','oui','oui','oui','non','non','non','oui',''),('Square Saint François',1747,'RUE SAINT FRANCOIS','Gare SNCF nord Line 1','non','oui','non','non','non','oui','non','non','non','oui','Petit square de proximité avec jeux dans le quartier Richebourg.'),('Douves du Château des Ducs',16410,'Rue des Etats','Bouffay Ligne 1','non','non','non','non','non','non','non','non','non','non',''),('Square Psalette',2387,'Cours St Pierre - Impasse St Laurent - Impasse de la Psalette','Saint Pierre Lignes 11 12 21 22 23 C Lu','non','oui','non','non','non','oui','non','non','non','non',''),('Place Wattignies',2753,'Place Wattignies - Rue de l\'Echappée - Rue petite Biesse','Wattignies Lignes 2 3','non','non','non','non','non','non','non','non','non','non',''),('Jardin des quatre jeudis',13010,'RUE DE L\'EMBELLIE SAINT JOSEPH DE PORTERIE','Portricq 22 - Embellie 22','non','oui','non','non','non','non','non','non','non','oui','Jardin situé à proximité du bourg de Saint Joseph de Porterie. Il a permis la conservation d\'un petit bois lors de la création de la ZAC. Des jeux d\'enfants permettent une animation au coeur du quartier.'),('Jardin du Nadir',2897,'RUE DU NADIR SAINT JOSEPH DE PORTERIE','Embellie Ligne 22','non','oui','non','non','non','non','non','non','non','oui','Petit square de quartier situé à Saint Joseph de Porterie avec des jeux pour enfants.'),('Jardin du Zenith',1595,'RUE TRISTAN CORBIERES SAINT JOSEPH DE PORTERIE','Saint Joseph Porterie Ligne 22','non','oui','non','non','non','non','non','non','non','oui','Petit square de quartier situé à Saint Joseph de Porterie, entouré de pergolas de bois et de plantations de rosiers,'),('Jardin des Farfadets',3747,'ALLEE DE PORTRICK SAINT JOSEPH DE PORTERIE','Linot Lignes 22 C72 76','non','non','non','non','non','non','non','non','non','non','Petit square de quartier situé à Saint Joseph de Porterie\n\nUne plantation régulière de pommiers fleurs isole une pelouse permettant les jeux de ballon au milieu du verger, Des plantations de petits fruits forment des haies à l\'ancienne.'),('PARC DE LA CHANTRERIE',176600,'ROUTE DE GACHET','Tram ligne 1 puis bus ligne 72, 76','non','oui','non','oui','non','non','oui','non','oui','oui',''),('Parc potager Fournillère',31570,'Rue Jules Piedeleu','Danais Ligne 24','non','oui','non','non','non','non','non','oui','oui','oui','Depuis le XIX ème siècle à cet emplacement, le hameau de la Fournillière a disposé tour à tour de pâtures communes, vergers ou jardins ouvriers. Fruit d\'une revendication des jardiniers pour la sauvegarde de leurs potagers et d\'une demande forte des habitants pour la création d\'un espace vert au coeur du quartier Zola, le parc potager de la Fournillière perpétue la tradition sur près de  4 hectares. A la fois jardins familiaux avec une centaine de parcelles et parc urbain ouvert aux promeneurs, la Fournillière est concue autour de ces deux fonctions distinctes et complémentaires. Ce parc comprend aussi des jeux pour enfants, des tables de pique nique et de nombreux fruitiers. Chiens tenus en laisse.'),('Aire du Stade de la Beaujoire',105400,'ROUTE DE SAINT JOSEPH','Beaujoire 46 72 76 EB - Halveque 1','non','non','non','non','non','non','non','non','non','non','La création du stade de la Beaujoire a permis de créer un parc rustique aux abords de cet équipement, très utilisé comme zone récréative pour les promeneurs du quartier de la Halvêque.'),('Square du Vieux Parc de Sèvre',331,'AVENUE CAMILLE GUERIN','Roches vertes Lignes 30 42','non','oui','non','non','non','non','non','non','non','non','Le square du Vieux parc de Sèvre était à l\'origine le parc d\'une maternité.\n\nExceptionnellement en période de crue importante de la Sèvre, une partie du parc peut héberger les vaches écossaises vivantt habituellement sur les prés de Sèvre.'),('Parc des Chantiers',13000,'Boulevard Léon Bureau - Boulevard de la Prairie au','Tram ligne 1','non','oui','non','non','non','non','non','non','oui','oui',''),('Parc potager Croissant',22320,'Avenue Jacques Auneau - Rue des Clématites','Bois Robillard Ligne 11','non','oui','non','non','non','non','non','oui','oui','oui',''),('PARC DE LA GAUDINIERE',125000,'Carrefour Patouillerie - Robert Schuman','Pont du Cens Lignes 12 - 25 - 32 - 87 - 96','oui','oui','non','oui','non','oui','non','oui','non','oui',''),('Square de la Halvèque',28170,'RUE LEON SERPOLLET','Halveque 1 - Malraux 95','non','oui','oui','non','non','non','non','non','oui','oui','Plaine de jeux particulièrement attractive pour le quartier avec de nombreux jeux pour enfants et une pataugeoire bien intègrée dans les équipements publics (bibliothèque, centre social ....)\n\nLa pataugeoire est agrémentée de jeux à déclenchement aléatoire via une borne : jets d\'eau, serpent douche'),('Square Jean Heurtin',813,'QUAI FERDINAND FAVRE','Favre 09 24 56 A - Cité des Congrès 4','non','non','non','non','non','non','non','non','non','non','Ce petit square situé dans la ZAC de la Madeleine Champs de Mars et ouvert en 1998 est planté de nombreux camellias afin de commémorer Jean Heurtin, pépiniériste nantais, célèbre obtenteur de la fin du XIX ème.'),('PARC POTAGER DE LA CRAPAUDINE',16580,'AVENUE DES PALMIERS','Palmiers Ligne 42','non','oui','non','non','non','oui','non','oui','oui','oui','En 1998, un groupe d’une douzaine de personnes fonde une association afin de réaliser un projet de jardins familiaux et de jardin pédagogique sur une réserve foncière de la ville située entre Saint Jacques et Sèvres : L’association des jardins de la Crapaudine.\n\nSur cette réserve, un étang a été préservé où vivent des crapauds accoucheurs qui ont donné le nom au jardin. La crapaudine est également le nom d’une betterave. Ces terrains étaient utilisés autrefois aux productions maraîchère et horticole.\n\nCe site est accessible à tous , seul l’accès aux parcelles potagères est bien sur réservé aux jardiniers. Elles peuvent néanmoins être découvertes à partir des allées qui les désservent ce qui constitue l’originalité de ce parc.'),('Parc de la Moutonnerie',15670,'RUE FRANCISCO FERRER','Moutonnerie Lignes 1 12','non','oui','non','non','non','non','non','non','non','oui','Le parc de la Moutonnerie a été ouvert en 1997, aménagé sur le thème des jeux de société, on y trouve une aire de jeux pour enfants, un espace sportif de proximité, une dizaine de jardins familiaux et un vaste espace gazonné.'),('Place de la Guirouée',1345,'PLACE DE LA GUIROUEE','Pompidou Ligne 24','non','oui','non','non','non','oui','non','non','non','non','Réalisé en 2000,en complément de la Place Basse Mar, il accueille les petits en toute sécurité avec quelques jeux,'),('Square Barbara',396,'Rue de la Grange au loup','Linot 22','non','non','non','non','non','non','non','non','non','non','Dans sa chanson « Nantes », la chanteuse Barbara évoque la « rue de la Grange au Loup » où elle vient retrouver, trop tard, son père mourant. Cette rue n’existait pas à l’époque, mais le père de Barbara occupait bien dans le quartier de St Joseph de Porterie une dépendance de la ferme « Rincé » où se situe l’actuelle cité des Castors. En 1986, la municipalité décide de baptiser la rue de la Grange au Loup, en présence de l’artiste et de l’acteur Gérard Depardieu. Après le décès de la chanteuse en 1997, la Commune Libre de St Joseph de Porterie est à l’initiative de ce square Barbara inauguré en 2000. Outre une statue de Jeanne Merlet à l’effigie de l’artiste et une fresque de Philippe Béranger illustrant son parcours artistique, le jardin est planté de végétaux présents dans son œuvre : rosiers, mimosa, glycine, lilas, romarin, etc.'),('SQUARE DU LAIT DE MAI',1747,'rue Berthault','Hotel Dieu Lignes 2 et 3','non','oui','non','non','oui','oui','non','oui','non','oui','Inauguré en juin 2002, ce jardin public de taille humaine, est situé entre la rue Péhant et la rue Berthault.\n\nAbritée sous une pergola, une fontaine de mosaïque réalisée par Delphine Deltombe.\n\nA l\'opposé, une petite maison de brique et de bois construite par le service de la Maintenance du Seve sur le modèle des abris construits à la fin du XIXeme aux abords des usines ou dans les jardins. C\'est une petite maison en ruine découverte à proximité du chantier qui a servi de modèle.\n\nLa conception de ce jardin a reposé sur un travail d\'équipe, regroupant le Seve et les associations du quartier du Champ de Mars. Les habitants ont contribué au projet en apportant idées et suggestions.'),('Square Saint Pasquier',395,'Place Emile Fritsch','Leon Say Ligne 51','non','non','non','oui','non','non','non','non','non','oui','Ce petit square très confidentiel proche de l\'église offre la possibilité de se reposer près des grands arbres.'),('Espace de jeux de Belle ile',2791,'Rue Coetquelfen','Bonneville Ligne 52','non','oui','non','non','non','non','non','non','oui','oui',''),('SQUARE DES MARAICHES',5672,'Rue de la Haluchère - Rue Emile Gadeceau','Pin Sec Ligne 1','non','oui','non','non','oui','oui','oui','oui','non','oui','Le square \"le jardin des Maraîches\" a été créé en 2003 en concertation avec les habitants autour du thème et fil conducteur du maraîchage, pour rappeler l\'ancienne activité du site.\n\nLe mot maraîche était utilisé autrefois populairement par les gens du quartier et plus particulièrement par les enfants lorsqu\'ils entraient sur les tenues maraîchères.'),('Square Louis Feuillade',3928,'Rue Jacques Feyder','Avenue Blanche 54 F','non','oui','oui','oui','oui','oui','non','non','non','non','Inscrit dans la réhabilitation du quartier dans les années 2000, la mise en place d\'aires de jeux, de tables de pique nique et la végétalisation des abords, facilitent l\'approporiation par les habitants de cet espace clos. La pataugeoire reste un rendez vous incontournable durant l\'été pour les enfants en quête d\'activités avec l\'eau. Square interdit aux chiens, sanitaires à l\'entrée.'),('Jardin Mabon',2686,'Quai François Mitterrand','Médiathèque Ligne 1 - Maison Syndicats 58B','non','oui','non','non','non','oui','non','non','oui','non','Le respect de l\'héritage historique de l\'Ile de nantes et la revalorisation de l\'existant étaient les axes prioritaires du réaménagement entrepris par l\'équipe Chémétoff. C\'est une friche de l\'usine Alstom où une végétation spontanée s\'était développée sur une dalle de béton qui est devenue le jardin Mabon. Depuis 2005, aucun végétal n’a été planté, tout ce qui pousse est spontané. Un chemin de découverte constitué de caillebotis métallique permet d\'évoluer au coeur de la végétation. Des tables de pique-nique ont été installées le long d’un mur de schiste conservé. L\'équipe de jardiniers en charge du jardin a procédé à l\'inventaire botanique et a constitué un herbier présenté sur le site. L\'évolution de la végétation fait depuis l\'objet d\'un suivi de la part des botanistes du Seve. La seule intervention des jardiniers consiste à maintenir l\'accessibilité des allées parcourant le jardin.'),('Jardin des Nectars',2027,'Petite Avenue de Lonchamp','Tram ligne 3 Beauséjour','non','oui','non','non','oui','oui','non','oui','oui','oui','S\'inspirant des anciens vergers du site, le jardin est structuré par les lignes d\'arbres fruitiers en espaliers, Elles se prolongent dans l\'alignement des poiriers d\'ornements sur la rue et sur l\'allée de desserte de l\'école,'),('Square Félix Thomas',1796,'Rue Toulmouche - Rue Félix Thomas','Saint Félix Ligne 2','non','oui','non','non','oui','oui','non','non','non','oui','Au coeur du quartier Hauts Pavés, Saint Félix, le square Félix Thomas se situe dans l\'ancien site occupé par les ateliers municipaux transformés en locaux associatifs. L\'aménagement à partir de 2006 se compose de deux espaces à destination des enfants et d\'une zone gazonnée. L\'esprit du lieu est conservé en valorisant les métiers notamment du bois. Ainsi des bancs retracent différentes phases du savoir faire des compagnons.  Square interdit aux chiens, table de ping pong, panneau de basket, aires de jeux pour petits.'),('Parc potager Amande',84670,'Boulevard Albert Einstein','Einstein Ligne D 73','non','non','non','non','non','non','non','non','non','non',''),('Square Pilotière',3792,'Boulevard de la Pilotière - Boulevard Jules Verne','Platanes Ligne 23','non','oui','non','non','non','oui','non','non','non','non',''),('Square Zac Pilleux Nord',3803,'Rue de Pilleux - Rue Benoit Frachon','Du chaffault Ligne 1','non','oui','non','non','oui','oui','non','non','non','oui','Proche du boulevard Benoit Frachon et au coeur de deux opérations immobilières, un square a été aménagé offrant un véritable poumon vert paysager. On y retrouve des jeux pour enfants et des sentiers de promenades voués à la flanerie.'),('Square Hongrie',2976,'Rue de Hongrie - Rue de Chypre','Hongrie Lignes 56 58 A','non','oui','non','non','oui','oui','non','non','non','oui',''),('JARDIN DES FONDERIES',3600,'Rue Louis Joxe - Allée des Hélices - Rue de Récife','Vincent Gache Lignes 2 3','non','oui','non','non','non','non','oui','non','non','non',''),('Parc Pablo Picasso',1605,'Mail Pablo Picasso','Allier Lignes 24 56 A','non','oui','non','non','non','oui','non','non','oui','oui',''),('PARC DES OBLATES',30000,'Rue Boca Rue des Baronnies','Ligne bus 81 arrêt Bougainville','non','non','non','non','non','oui','non','non','non','non','');
/*!40000 ALTER TABLE `jardins` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `min_comment_lenth` BEFORE INSERT ON `jardins` FOR EACH ROW BEGIN
    IF LENGTH(NEW.Commentaire) < 40
    THEN
        SIGNAL SQLSTATE '12500' SET MESSAGE_TEXT = "Vous devez entrez un comentaire contenant d'autre inforations sur le parc";
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping routines for database 'jardins'
--
/*!50003 DROP PROCEDURE IF EXISTS `get_park_with_toilette` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_park_with_toilette`()
BEGIN
    SELECT NOM
    FROM jardins WHERE Sanitaires
    LIKE "Oui";
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_park_with_water` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_park_with_water`()
BEGIN
    SELECT NOM
    FROM jardins WHERE Eau
    LIKE "Oui";
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-11-11 17:34:30
                          

```

