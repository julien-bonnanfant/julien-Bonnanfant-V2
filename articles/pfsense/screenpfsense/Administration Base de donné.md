

# Administration Base de donné

---

Nous allons manipuler un jeu de donné, on travaillera sur une machine virtuel de Debian10 via SSH depuis macOS. 

## Description du jeu de données

Le jeux de donné choisit est a télécharger sur http://www.nosdonnees.fr/dataset/liste-des-jardins-publics-de-france, Il decrit les différents jardin de la ville de Nantes,leur nom, leur surface, leur adresse, les transport qui passe par ceux-ci, la presence de de gardien, de jeux, de pategeoire, de sanitaire, de jardin clos, d'abri, de point d'eau, de table de pic-nic, de sanitaire handicapé, si les chien son interdit ou non et un  commentaire concernant le placement du parc.

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
  Gardien BOOL,
  Jeux BOOL,
  Pataugeoire BOOL,
  Sanitaires BOOL,
  ChienInterdit BOOL,
  JardinsClos BOOL,
  Abris BOOL,
  Eau BOOL,
  TablePicNic BOOL,
  SanitaireHandicap BOOL,
  Commentaire VARCHAR (255)
)
```





