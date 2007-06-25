<?php

/**
 *Bernevig Ioan
 *i.bernevig@gmail.com 
 *Juin 2007
 **/  

/**
 *Les constantes
 *JERUSALEM_HTDOCS : le dossier o� se trouvent les fichiers constituant le site
 *ROMA_SYSTEM : l'emplacement de l'outil binaire roma
 *Ces deux chemins doivent �tre de pr�f�rence absolus
 *Pour une utilisation sans la base de donn�es, eXist, decommenter la ligne suivante en modifiant biensur les chemins
 * define("ROMA_SYSTEM", "/usr/bin/roma --xsl=/home/tei/sourceforge/trunk/Stylesheets --localsource=/home/tei/sourceforge/trunk/P5/Source/Guidelines/en/guidelines-en.xml")
 *Par d�faut, l'outil Roma en ligne de commande utilise la base de donn�es eXist tei.oucs.ox.ac.uk ! 
 **/
define("JERUSALEM_HTDOCS", "/home/tei/jerusalem/");
define("ROMA_SYSTEM", "/usr/bin/roma");

/**
 La classe SanityChecker v�rifie la coh�rence d'un sch�ma TEI.
 Elle se construit � partir d'un arbre DOM qui correspond au fichier ODD de personnalisation
 **/
class SanityChecker {
/**
 *COMPUTING    : tableau contenant les noms des �l�ments en cours de v�rification
 *RESULTS      : tableau contenant les noms des �l�ments dont on conna�t le r�sultat
 *DOM          : objet DOM qui repr�sente le fichier flat ODD en m�moire
 *FILE_TMP_NAME: le nom temporaire du fichier ODD sur le disque dur
 *ALL_ELEMENTS : liste de tous les elements dans le schema (m�me ceux non joignables)
 *ALL_CLASSES  : liste de toutes les classes
 *PGB_CURRENT  : avancement actuel de la barre de progression
 *PARENTS      : tableau associant � chaque nom d'�l�ment le "dernier parent connu"
 **/         
private $COMPUTING = array();
private $RESULTS = array();
private $DOM;
private $FILE_TMP_NAME;
private $ALL_ELEMENTS;
private $ALL_CLASSES;
private $PGB_CURRENT;
private $PARENTS;

/**
 La fonction constructeur
 Elle prend en param�tre l'arbre DOM du fichier de personnalisation ODD et le transforme en un arbre FLAT ODD
 **/
public function __construct($dom_customization) {
	$this->loadProgressBar();
	$this->FILE_TMP_NAME = md5(time());
	$fp = fopen(JERUSALEM_HTDOCS."tmp/".$this->FILE_TMP_NAME.".odd", "w");
	fwrite($fp, $dom_customization->saveXML());
	fclose($fp);
	$this->updateProgressBar(3);
	exec(ROMA_SYSTEM." --compile ".JERUSALEM_HTDOCS."tmp/".$this->FILE_TMP_NAME.".odd /");
	$xml_input = implode("", file(JERUSALEM_HTDOCS."tmp/".$this->FILE_TMP_NAME.".odd.compiled"));
	$this->DOM = new romaDom($xml_input);
	$this->updateProgressBar(10);
	$this->DOM->getXPath($xpath);
	$this->ALL_ELEMENTS = $xpath->query("//tei:elementSpec");
	$this->ALL_CLASSES = $xpath->query("//tei:classSpec");
	$this->PARENTS = array();
}

/**
 Fonction qui supprime les fichiers temporaires
 **/
private function deleteTemporary() {
	exec("rm ".JERUSALEM_HTDOCS."tmp/*.odd");
	exec("rm ".JERUSALEM_HTDOCS."tmp/*.compiled");
}

/**
 Fonction qui enl�ve les sp�cifications des s�quences dans les noms des classes
 On se sert pour retrouver le nom de la classe dans une r�f�rence qui porte des pr�cisions sur le type de s�quence.
 **/
private function remove_sequences_from_classnames($class) {
	if(ereg('_sequence', $class)) {
		$tab = explode('_sequence', $class);
		return $tab[0];
	} else {
		return $class;
	}
}

/**
 La fonction getContent renvoie
 un tableau d'�l�ments si l'�l�ment courant est un groupe, *, +, ?
 l'�l�ment contenu si l'�l�ment courant est un �l�ment (au sens TEI)
 un tableau d'�l�ments si l'�l�ment courant est une classe
 **/
private function getContent($input) {
	if($input->nodeName == "group" || $input->nodeName == "zeroOrMore" || $input->nodeName == "optional" || $input->nodeName == "oneOrMore") {
		$res = array();
		$childs = $input->childNodes;
		foreach($childs as $child) {
			if($child->nodeName == "ref") {
				$this->DOM->getXPath($xpath);
				$element = $xpath->query("//tei:elementSpec[@ident='".$child->getAttribute("name")."']")->item(0);
				$this->DOM->getXPath($xpath);
				$class = $xpath->query("//tei:classSpec[@ident='".$child->getAttribute("name")."']")->item(0);
				if(is_object($element)) $res[] = $element;
				if(is_object($class)) $res[] = $class;
			} else {
				$res[] = $child;
			}
		}
		return $res;
	} else if ($input->nodeName == "elementSpec") {
		$childs = $input->childNodes;
		foreach($childs as $child) {
			if($child->nodeName == "content") {
				return $child;
			}
		}
	} else if ($input->nodeName == "classSpec") {
		$res = array();
		$this->DOM->getXPath($xpath1);
		$items = $xpath1->query("//tei:*[tei:classes/tei:memberOf/@key='".$input->getAttribute("ident")."']");
		foreach($items as $item) {
			$res[] = $item;
		}
		return $res;
	}
}

/**
 La fonction isElement(element) renvoie si la la chaine pass�e en param�tres
 correspond ou pas � un �l�ment dans l'arbre DOM
 IE: il existe au moins un �l�ment elementSpec dont l'attribut @ident = element
 **/
private function isElement(&$element) {
	$this->DOM->getXPath($xpath);
	$tmp = $xpath->query("//tei:elementSpec[@ident='$element']" );
	if($tmp->length == 0) {
		return false;
	} else {
		return true;
	}
}

/**
 La fonction isClass(class) renvoie si la la chaine pass�e en param�tres
 correspond ou pas � une classe dans l'arbre DOM
 IE: il existe au moins un �l�ment classSpec dont l'attribut @ident = class
 **/
private function isClass(&$class) {
	$class = $this->remove_sequences_from_classnames($class);
	$this->DOM->getXPath($xpath);
	$tmp = $xpath->query("//tei:classSpec[@ident='$class' and @type='model']" );
	if($tmp->length == 0) {
		return false;
	} else {
		return true;
	}
}

/**
 La fonction computingStart(name) enregistre dans un tableau le fait que
 l'�l�ment name est "en cours de calcul"
 IE: on se trouve � l'int�rieur de la fonction verifElem(name)
 **/
private function computingStart($name) {
	if($name != "") $this->COMPUTING[$name] = true;
}

/**
 La fonction computingProgress(name) renvoie vrai si la fonction verifElem(name) 
 est en cours d'ex�cution sur l'�l�ment dont le nom est name
 **/
private function computingProgress($name) {
	if(trim($name) != "" && isset($this->COMPUTING[$name]) && $this->COMPUTING[$name]) {
		return true;
	} else {
		return false;
	}
}

/**
 La fonction computingStop(name) enregistre dans un tableau le fait que
 l'�l�ment name n'est plus "en cours de calcul"
 IE: la fonction verifElem(name) s'est termin�e
 **/
private function computingStop($name) {
	$this->COMPUTING[$name] = false;
}

/**
 La fonction getParentItem(element) est une fonction r�cursive qui renvoie le
 premier �l�ment "�l�ment TEI" ou classe qui est p�re de l'�l�ment en cours.
 Par exemple:
 <elementSpec ident="bla">
   <content>
     <group>
       <optional>
         <zeroOrMore>
           <ref name="truc"/>
 Supposons que l'�l�ment courant est l'�l�ment ref. getParentItem(element) ne
 renverra pas l'�l�ment zeroOrMore qui est son parent direct mais l'�l�ment
 <elementSpec ident="bla">.

 Cette fonction sert principalement dans l'affichage des messages d'erreur. Elle
 n'a aucun impact sur la v�rification de la coh�rence m�me.
 **/
private function getParentItem($element) {
	if($element->nodeName == "elementSpec" || $element->nodeName == "classSpec") {
		return $element;
	} else {
		return $this->getParentItem($element->parentNode);
	}
}

/**
 La fonction getElementName renvoie le nom de l'�l�ment courant.
 Plus pr�cis�ment:
 - la valeur de l'attribut @ident si l'�l�ment courant est <elementSpec> ou <classSpec>
 - la valeur de l'attribut @name si l'�l�ment courant est <ref> ou <rng:ref>
 - si on n'est ni dans un <elementSpec> ni dans un <classSpec> ni dans un <ref> ou
 un <rng:ref> la fonction s'appelle elle-m�me en passant en param�tre le p�re
 de l'�l�ment courant.
 Cette fonction est r�cursive.
 **/
private function getElementName($element) {
	if($element->nodeName == "elementSpec" || $element->nodeName == "classSpec") {
		return $element->getAttribute("ident");
	} else if($element->nodeName == "ref" || $element->nodeName == "rng:ref") {
		return $element->getAttribute("name");
	} else {
		return $this->getElementName($element->parentNode);
	}
}

/**
 La fonction inOptionnality(element) renvoie si quelque part au dessus dans 
 l'hi�rarchie il existe un �l�ment qui ne soit pas obligatoire.
 IE: Il existe au moins un �l�ment "zeroOrMore" OU "optionnal" OU "choice" 
 (quoi que pour choice, c'est un cas sp�cial) parmi les p�res (et les p�res
 des p�res, et ainsi de suite) de l'�l�ment element.
 **/
private function inOptionnality($recursion) {
	foreach($recursion as $recursion_item) {
		if($recursion_item->nodeName == "zeroOrMore" || $recursion_item->nodeName == "optional" || $recursion_item->nodeName == "choice") {
			return true;
		}
	}
	return false;
}

/**
 Ajoute l'�l�ment courant � la liste de la r�cursion
 **/
private function addRecursion($recursion, $element) {
	$recursion[] = $element;
	return $recursion;
}

/**
 La fonction verifElem(element, parent) est la principale fonction de l'algorithme.
 Elle renvoie
 vrai : si l'�l�ment pass� en param�tre est satisfiable (ie: son contenu est satifiable)
 faux : si l'�l�ment pass� en param�tre n'est pas satifisable (ie: son contenu n'est pas satisfiable)

 Cette fonction est r�cursive. La premier appel � cette fonction se fait sur l'�l�ment racine.
 Souvent, cet �l�ment racine est l'�l�ment <TEI> mais on peut avoir �galement d'autres racines possibles.
 Un sch�ma est "cass�" lorsque toutes les racines que ce sch�ma peut avoir sont cass�es, IE
 la fonction verifElem renvoie faux pour chaque racine.

 Le principe de cette fonction est assez simple:
 Si l'�l�ment a d�j� �t� v�rifi�, on renvoie le r�sultat de la v�rification pr�c�dente.
 Si l'�l�ment est en cours de v�rification, on le consid�re comme non satifiable jusqu'� preuve du contraire.

 Si l'�l�ment courant est un �l�ment: on v�rifie tous les �l�ments qui sont dans son contenu. Si un seul de ces �l�ments est non satisfiable, l'�l�ment courant est non satisfiable. Si l'�l�ment n'a pas de contenu, c'est �galement une erreur.
 Si l'�l�ment courant une une classe: on v�rifie chaque �l�ment membre de cette classe. Si � la fin de la v�rification il ne reste plus aucun membre satisfiable dans cette classe, cette classe est consid�r�e comme vide. Il est tenu compte des sequences, s�quences r�p�tables etc qui peuvent s'appliquer aux classes (cas particuliers).
 Si l'�l�ment courant est une s�quence d'�l�ments: on v�rifie tous les �l�ments fils. Si un seul de ces �l�ments est non satisfiable, la s�quence est consid�r� comme non satisfiable car la s�quence a �t� interrompue.
 Si l'�l�ment courant est un "zeroOrMore" ou "optionnal": On v�rifie tous les �l�ments fils mais on ne tient pas compte du r�sultat. On renvoie vrai.
 Si l'�l�men courant est un "oneOrMore" ou "choice": On v�rifie tous les �l�ments fils. On renvoie vrai s'il y en a au moins un qui est satifisable, faux sinon.
 Si l'�l�ment courant est un �l�ment terminal comme "text", "rng:text", "rng:empty", "s:patter", "sch:pattern" on renvoie vrai.
 Si l'�l�ment courant est une r�f�rence vers un �l�ment ou une classe ("ref" ou "rng:ref"): on v�rifie l'�l�ment ou la classe correspondante. On renvoie vrai si l'�l�ment sur lequel le pointeur pointe est satifiable, faux sinon.

 A chaque erreur trouv�e, on doit renvoyer un message d'erreur. Le soucis est de savoir si l'erreur trouv�e est une erreur ou un warning. C'est pour cel� qu'on v�rifie s'il y a une optionnalit� parmi les �l�ments parents. S'il y a une optionnalit�, cette optionnalit� arretera la propagation de l'erreur, et on envoie un warning � l'utilisateur. S'il n'y a pas d'optionnalit� parmi les �l�ments p�res, l'erreur se propagera jusqu'� la racine et rendera le sch�ma incoh�rent de fa�on � n'avoir aucun document XML qui puisse le valide. Dans ce cas, on doit envoie le message sous la forme d'une erreur.
 **/
private function verifElem(&$element, &$parent, $recursion) {
$this->getParentItem($element);
	if(!is_object($element)) return null;
	$ident = $element->getAttribute("ident");
	$name = $element->nodeName;
	if($ident != "") $this->PARENTS[$element->getAttribute("ident")][] = $parent;
	if($ident != "" && isset($this->RESULTS[$ident])) {
		return $this->RESULTS[$ident];
	}
	if(!$this->computingProgress($ident)) {
		$this->increaseProgressBar();
		//echo "verifElement: name=$name"; if($element->getAttribute("ident") != "") echo ", @ident=$ident"; if($element->getAttribute("name") != "") echo ", @name=".$element->getAttribute("name"); echo "\n";
		switch($name) {
		case "elementSpec": {
			$content = $this->getContent($element);
			$broken = false;
			$this->computingStart($ident);
			foreach($content->childNodes as $content_item) {
				if(!$this->verifElem($content_item, &$element, $this->addRecursion($recursion, $element))) {
					$broken = true;
					$faulty = $content_item;
				}
			}
			$this->computingStop($ident);
			if($broken) {
				if(!$this->computingProgress($ident) && $ident != $this->getElementName($faulty)) $this->sanityCheckAddError($ident, " has NO VALID CONTENT because ".$this->getElementName($faulty)." neither and is used in ", $this->getElementName($parent), "");
				$this->RESULTS[$ident] = false;
				return false;
			}
			break;
		}
		case "classSpec": {
			$sequence = "";
			if(isset($parent) && $parent->nodeName == "ref") {
				$tmp = explode("_", $parent->getAttribute("name"));
				if(isset($tmp[1])) $sequence = $tmp[1];
			}
			$broken = false;
			$content = $this->getContent($element);
			$sequence_broken = false;
			$count = count($content);
			$this->computingStart($ident);
			foreach($content as $content_item) {
				if(!$this->verifElem($content_item, &$parent, $this->addRecursion($recursion, $element))) {
					$count--;
					$sequence_broken = true;
				}
			}
			$this->computingStop($ident);
			if($count == 0) {
				if(!$this->computingProgress($this->getElementName($element))) $this->sanityCheckAddWarning($ident, " is EMPTY  and is used in ", "", $this->getParentItem($parent)->getAttribute("ident"));
				$this->RESULTS[$ident] = false;
				return false;
			}
			if(($sequence == "sequence" || $sequence == "sequenceRepeatable") && $sequence_broken) {
				if(!$this->computingProgress($this->getElementName($element))) $this->sanityCheckAddWarning("$ident sequence is broken");
				$this->RESULTS[$ident] = false;
				return false;
			}
			break;
		}
		case "group": {
			$broken = false;
			foreach($element->childNodes as $content_item) {
				if(!$this->verifElem($content_item, &$element, $this->addRecursion($recursion, $element))) {
					$broken = true;
					$faulty = $content_item;
				}
			}
			if($broken) {
				if($this->inOptionnality($this->addRecursion($recursion, $element))) {
					if(!$this->computingProgress($this->getElementName($element))) $this->sanityCheckAddWarning($this->getElementName($this->getParentItem($parent)), " group broken ", "", "");
				} else {
					if(!$this->computingProgress($this->getElementName($element))) $this->sanityCheckAddError($this->getElementName($this->getParentItem($parent)), " group broken ", "", "");
				}
				return false;
			}
			break;
		}
		case "oneOrMore": {
			$count = 0;
			foreach($element->childNodes as $content_item) {
				if($this->verifElem($content_item, &$element, $this->addRecursion($recursion, $element))) $count++;
				else $faulty = $content_item;
			}
			if($count == 0) {
				if(!$this->computingProgress($this->getElementName($element))) $this->sanityCheckAddError($this->getElementName($faulty), " is required at least once in ", $this->getElementName($this->getParentItem($parent)), " !");
				return false;
			}
			break;
		}
		case "zeroOrMore": {
			foreach($element->childNodes as $content_item) {
				$this->verifElem($content_item, &$element, $this->addRecursion($recursion, $element));
			}
			break;
		}
		case "choice": {
			$good_ones = $element->childNodes->length;
			foreach($element->childNodes as $content_item) {
				if(!$this->verifElem($content_item, &$element, $this->addRecursion($recursion, $element))) $good_ones--;
			}
			if($good_ones == 0) {
				return false;
			}
			break;
		}
		case "optional": {
			foreach($element->childNodes as $content_item) {
				$this->verifElem($content_item, &$element, $this->addRecursion($recursion, $element));
			}
			break;
		}
		case "text":
		case "rng:text":
		case "rng:empty":
		case "s:pattern":
		case "sch:pattern": {
			break;
		}
		case "rng:ref":
		case "ref": {
			$this->DOM->getXPath($xpath);
			if($this->isClass($element->getAttribute("name"))) {
				$el = $xpath->query("//tei:classSpec[@ident='".$this->remove_sequences_from_classnames($element->getAttribute("name"))."']")->item(0);	
			} else if ($this->isElement($element->getAttribute("name"))) {
				$el = $xpath->query("//tei:elementSpec[@ident='".$element->getAttribute("name")."']")->item(0);
			} else {
				if($this->inOptionnality($this->addRecursion($recursion, $element))) {
					$this->sanityCheckAddWarning($element->getAttribute("name"), " does NOT EXIST  and is used in ", $this->getParentItem($element)->getAttribute("ident"), ". It could be in ".$this->getParentItem($element)->getAttribute("module")." module.");
				} else {
					$this->sanityCheckAddError($element->getAttribute("name"), " does NOT EXIST  and is used in ", $this->getParentItem($element)->getAttribute("ident"), ". It could be in ".$this->getParentItem($element)->getAttribute("module")." module.");
				}
				return false;
			}
			if($el->nodeName != "") {
				return $this->verifElem($el, &$element, $this->addRecursion($recursion, $element));
			}
			break;
		}
		default: {
			$this->sanityCheckAddError("I can't process $name");
			return false;
		}
		}
		if($ident != "") $this->RESULTS[$ident] = true;
		return true;
	} else {
		return false;
	}
}

/**
 Charge la barre de progression
 **/
public function loadProgressBar() {
	echo '<script type="text/javascript">';
	echo "showPgb();";
	echo '</script>';
	flush();
}

/**
 Met � jour le curseur de la barre de progression
 **/
public function updateProgressBar($nPercentage) {
	echo '<script type="text/javascript">';
	echo "setPgb('pgbMain', '{$nPercentage}');";
	echo '</script>';
	flush();
	$this->PGB_CURRENT = $nPercentage;
}

/**
 Incr�mente de 1 la barre de progresion
 **/
public function increaseProgressBar() {
	$min = 10;
	$max = 100;
	$current = $this->PGB_CURRENT;
	$nb_el = $this->ALL_ELEMENTS->length;
	$nb_class = $this->ALL_CLASSES->length;
	$verified = count($this->RESULTS);
	$state = round(($verified/($nb_el+$nb_class))*($max-$min)) + $min;
	$this->updateProgressBar($state);
}

/**
 Ajoute un message d'erreur
 **/
private function sanityCheckAddError($el_name, $prepend, $bold, $append) {
	echo '<script type="text/javascript">';
	echo "addError('".$el_name."', '".$prepend."', '".$bold."', '".$append."');";
	echo '</script>';
	flush();
}

/**
 Ajoute un avertissement
 **/
private function sanityCheckAddWarning($el_name, $prepend, $bold, $append) {
	echo '<script type="text/javascript">';
	echo "addWarning('".$el_name."', '".$prepend."', '".$bold."', '".$append."');";
	echo '</script>';
	flush();
}

/**
 Ajoute le message qui dit que le sch�ma est invalide
 **/
private function sanityCheckSchemaBroken() {
	echo '<script type="text/javascript">';
	echo "schemaBroken('Schema is broken !');";
	echo '</script>';
	flush();
}

/**
 Est-ce que le sch�ma est coh�rent ?
 pass1() v�rifie si toutes les racines du sch�ma sont satisfiables
**/
public function pass1() {
	$this->DOM->getXPath($xpath);
	$roots = explode(" ", $xpath->query("//tei:schemaSpec")->item(0)->getAttribute("start"));
	if(trim($roots[0]) == "") {
		$roots = array();
		$roots[0] = "TEI";
	}
	foreach($roots as $root) {
		$tmp = $xpath->query("//tei:elementSpec[@ident='".$root."']")->item(0);
		$root_node = $this->DOM->rootNode;
		if(!$this->verifElem($tmp, $root_node, array())) $schema_broken = true;
	}
	if($schema_broken) {
		$this->sanityCheckSchemaBroken();
		return true;
	} else {
		return false;
	}
}

/**
 Est-ce que tous les �l�ments sont joignables � partir des racines ?
 **/
public function pass2() {
	$res = true;
	$this->DOM->getXPath($xpath);
	foreach($this->ALL_ELEMENTS as $element) {
		if(!isset($this->COMPUTING[$element->getAttribute("ident")])) {
			$res = false;
			$this->sanityCheckAddWarning($element->getAttribute("ident"), " is not reacheable from root", "", "");
		}
	}
	$this->updateProgressBar(95);
	return $res;
}

/**
 *Est-ce qu'il y a des cas o� les �l�ments bouclent sur eux-m�mes
 **/
public function pass3() {
	$res = true;
	$this->DOM->getXPath($xpath);
	echo '<table><tr><td><pre>';
  print_r($this->COMPUTING);
  echo '</pre></td><td>'
  print_r($this->RESULTS);
  echo '</td></tr></table>'
 	$this->updateProgressBar(100);
	return $res;
}

}

?>
