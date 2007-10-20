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
define("JERUSALEM_HTDOCS", "/");
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
 *PARENTS      : tableau associant � chaque nom d'�l�ment le "dernier parent connu"
 *SCEH         : sanity checker error handler 
 **/         
public $COMPUTING = array();
public $RESULTS = array();
private $DOM;
private $FILE_TMP_NAME;
public $ALL_ELEMENTS;
public $ALL_CLASSES;
private $PARENTS;
private $SCEH;

/**
 La fonction constructeur
 Elle prend en param�tre l'arbre DOM du fichier de personnalisation ODD et le transforme en un arbre FLAT ODD
 **/
public function __construct($odd) {
	$this->SCEH = new SanityCheckerErrorHandler($this);
	$this->SCEH->updateProgressBar(3);
        $this->DOM = new romaDom();	
	$odd->getOddDom($this->DOM);
	$this->SCEH->updateProgressBar(4);
        $this->xpath = new domxpath( $this->DOM );
	$this->SCEH->updateProgressBar(5);
	$this->xpath->registerNamespace( 'rng', 'http://relaxng.org/ns/structure/1.0' );
	$this->xpath->registerNamespace( 'tei', 'http://www.tei-c.org/ns/1.0' );
	$this->ALL_ELEMENTS = $this->xpath->query("//tei:elementSpec");
	$this->ALL_CLASSES = $this->xpath->query("//tei:classSpec");
	$this->PARENTS = array();
//   foreach($this->ALL_CLASSES as $oElement) {
//     print " + " . $oElement->nodeValue;
//     }
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
				$element = $this->xpath->query("//tei:elementSpec[@ident='".$child->getAttribute("name")."']")->item(0);
				$class = $this->xpath->query("//tei:classSpec[@ident='".$child->getAttribute("name")."']")->item(0);
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
		$items = $this->xpath->query("//tei:*[tei:classes/tei:memberOf/@key='".$input->getAttribute("ident")."']");
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
	$tmp = $this->xpath->query("//tei:elementSpec[@ident='$element']" );
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
	$tmp = $this->xpath->query("//tei:classSpec[@ident='$class' and @type='model']" );
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
 La fonction verifElem(element, parent) est la principale fonction de
 l'algorithme.  Elle renvoie vrai : si l'�l�ment pass� en param�tre
 est satisfiable (ie: son contenu est satifiable) faux : si l'�l�ment
 pass� en param�tre n'est pas satifisable (ie: son contenu n'est pas
 satisfiable)

 Cette fonction est r�cursive. La premier appel � cette fonction se
 fait sur l'�l�ment racine.  Souvent, cet �l�ment racine est l'�l�ment
 <TEI> mais on peut avoir �galement d'autres racines possibles.  Un
 sch�ma est "cass�" lorsque toutes les racines que ce sch�ma peut
 avoir sont cass�es, IE la fonction verifElem renvoie faux pour chaque
 racine.

 Le principe de cette fonction est assez simple:

 Si l'�l�ment a d�j� �t� v�rifi�, on renvoie le r�sultat de la
 v�rification pr�c�dente.
 
 Si l'�l�ment est en cours de v�rification, on le consid�re comme non
 satifiable jusqu'� preuve du contraire.

 Si l'�l�ment courant est un �l�ment: on v�rifie tous les �l�ments qui
 sont dans son contenu. Si un seul de ces �l�ments est non
 satisfiable, l'�l�ment courant est non satisfiable. Si l'�l�ment n'a
 pas de contenu, c'est �galement une erreur.

 Si l'�l�ment courant une une classe: on v�rifie chaque �l�ment membre
 de cette classe. Si � la fin de la v�rification il ne reste plus
 aucun membre satisfiable dans cette classe, cette classe est
 consid�r�e comme vide. Il est tenu compte des sequences, s�quences
 r�p�tables etc qui peuvent s'appliquer aux classes (cas
 particuliers).

 Si l'�l�ment courant est une s�quence d'�l�ments: on v�rifie tous les
 �l�ments fils. Si un seul de ces �l�ments est non satisfiable, la
 s�quence est consid�r� comme non satisfiable car la s�quence a �t�
 interrompue.

 Si l'�l�ment courant est un "zeroOrMore" ou "optionnal": On v�rifie
 tous les �l�ments fils mais on ne tient pas compte du r�sultat. On
 renvoie vrai.

 Si l'�l�men courant est un "oneOrMore" ou "choice": On v�rifie tous
 les �l�ments fils. On renvoie vrai s'il y en a au moins un qui est
 satifisable, faux sinon.

 Si l'�l�ment courant est un �l�ment terminal comme "text",
 "rng:text", "rng:empty", "s:pattern", "sch:pattern" on renvoie vrai.

 Si l'�l�ment courant est une r�f�rence vers un �l�ment ou une classe
 ("ref" ou "rng:ref"): on v�rifie l'�l�ment ou la classe
 correspondante. On renvoie vrai si l'�l�ment sur lequel le pointeur
 pointe est satifiable, faux sinon.

 A chaque erreur trouv�e, on doit renvoyer un message d'erreur. Le
 soucis est de savoir si l'erreur trouv�e est une erreur ou un
 warning. C'est pour cel� qu'on v�rifie s'il y a une optionnalit�
 parmi les �l�ments parents. S'il y a une optionnalit�, cette
 optionnalit� arretera la propagation de l'erreur, et on envoie un
 warning � l'utilisateur. S'il n'y a pas d'optionnalit� parmi les
 �l�ments p�res, l'erreur se propagera jusqu'� la racine et rendera le
 sch�ma incoh�rent de fa�on � n'avoir aucun document XML qui puisse le
 valide. Dans ce cas, on doit envoie le message sous la forme d'une
 erreur.  **/ 

private function verifElem($element, $parent,  $recursion) { 
 if(!is_object($element)) return null; 
 $name = $element->nodeName;
 if ($name == 'elementSpec' ) {
    	    $ident = $element->getAttribute("ident"); 
	    }
 else
  if ($name == 'classSpec' ) {
    	    $ident = $element->getAttribute("ident"); 
 }
 else 
     { $ident = ''; }

 if($ident != "") $this->PARENTS[$ident][] = $parent;
 if($ident != "" && isset($this->RESULTS[$ident])) {
		return $this->RESULTS[$ident];
	}
 if(!$this->computingProgress($ident)) {
		$this->SCEH->increaseProgressBar();
		//echo "verifElement: name=$name";
// if($element->getAttribute("ident") != "") echo ", @ident=$ident";
// if($element->getAttribute("name") != "") echo ",
// @name=".$element->getAttribute("name"); echo "\n";

		switch($name) {
		case "elementSpec": {
			$content = $this->getContent($element);
			$broken = false;
			$this->computingStart($ident);
			foreach($content->childNodes as $content_item) {
				if(!$this->verifElem($content_item, $element, $this->addRecursion($recursion, $element))) {
					$broken = true;
					$faulty = $content_item;
				}
			}
			$this->computingStop($ident);
			if($broken) {
				if(!$this->computingProgress($ident) && $ident != $this->getElementName($faulty)) $this->SCEH->addError('Error', $ident, $this->getElementName($parent), 'has NO VALID CONTENT because '.$this->getElementName($faulty).' neither');
				//$this->RESULTS[$ident] = false;
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
			$parentSpec = $this->getParentItem($element);
			foreach($content as $content_item) {
				if(!$this->verifElem($content_item, $parentSpec, $this->addRecursion($recursion, $element))) {
					$count--;
					$sequence_broken = true;
				}
			}
			$this->computingStop($ident);
			if($count == 0) {
				if(!$this->computingProgress($this->getElementName($element))) $this->SCEH->addError('Warning', $ident, $this->getParentItem($parent)->getAttribute("ident"), 'is empty');
				//$this->RESULTS[$ident] = false;
				return false;
			}
			if(($sequence == "sequence" || $sequence == "sequenceRepeatable") && $sequence_broken) {
				if(!$this->computingProgress($this->getElementName($element))) $this->SCEH->addError('Error', $ident, '', 'sequence broken');
				//$this->RESULTS[$ident] = false;
				return false;
			}
			break;
		}
		case "group": {
			$broken = false;
			foreach($element->childNodes as $content_item) {
				if(!$this->verifElem($content_item, $element, $this->addRecursion($recursion, $element))) {
					$broken = true;
					$faulty = $content_item;
				}
			}
			if($broken) {
				if($this->inOptionnality($this->addRecursion($recursion,
	$element))) {
					if(!$this->computingProgress($this->getElementName($element))) $this->SCEH->addError('Warning', $this->getElementName($this->getParentItem($parent)), '', 'group broken' );
				} else {
					if(!$this->computingProgress($this->getElementName($element))) $this->SCEH->addError('Error', $this->getElementName($this->getParentItem($parent)), '', 'group broken' );
				}
				return false;
			}
			break;
		}
		case "oneOrMore": {
			$count = 0;
			foreach($element->childNodes as $content_item) {
				if($this->verifElem($content_item, $element, $this->addRecursion($recursion, $element))) $count++;
				else $faulty = $content_item;
			}
			if($count == 0) {
				if(!$this->computingProgress($this->getElementName($element))) $this->SCEH->addError('Error', $this->getElementName($faulty), $this->getElementName($this->getParentItem($parent)), 'is required at least once' );
				return false;
			}
			break;
		}
		case "zeroOrMore": {
			foreach($element->childNodes as $content_item) {
				$this->verifElem($content_item, $element, $this->addRecursion($recursion, $element));
			}
			break;
		}
		case "choice": {
			$good_ones = $element->childNodes->length;
			foreach($element->childNodes as $content_item) {
				if(!$this->verifElem($content_item, $element, $this->addRecursion($recursion, $element))) $good_ones--;
			}
			if($good_ones == 0) {
				return false;
			}
			break;
		}
		case "optional": {
			foreach($element->childNodes as $content_item) {
				$this->verifElem($content_item, $element, $this->addRecursion($recursion, $element));
			}
			break;
		}
		case "#text":
		case "text":
		case "rng:text":
		case "rng:empty":
		case "s:pattern":
		case "sch:pattern": {
			break;
		}
		case "rng:ref":
		case "ref": {

			if($this->isClass($element->getAttribute("name"))) {
				$el = $this->xpath->query("//tei:classSpec[@ident='".$this->remove_sequences_from_classnames($element->getAttribute("name"))."']")->item(0);	
			} else if ($this->isElement($element->getAttribute("name"))) {
				$el = $this->xpath->query("//tei:elementSpec[@ident='".$element->getAttribute("name")."']")->item(0);
			} else {
				if($this->inOptionnality($this->addRecursion($recursion, $element))) {
				  $this->SCEH->addError('Warning', $element->getAttribute("name"), $this->getParentItem($element)->getAttribute("ident"), 'does not exist');
				} else {
					$this->SCEH->addError('Error', $element->getAttribute("name"), $this->getParentItem($element)->getAttribute("ident"), 'does not exist');
				}
				return false;
			}
			if($el->nodeName != "") {
				return $this->verifElem($el, $element, $this->addRecursion($recursion, $element));
			}
			break;
		}
		default: {
			error_log("I can't process ". $name);
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
 Est-ce que le sch�ma est coh�rent ?
 pass1() v�rifie si toutes les racines du sch�ma sont satisfiables
**/
public function pass1() {
	$this->SCEH->updateProgressBar(51.1);
	$roots = explode(" ",
    $this->xpath->query("//tei:schemaSpec")->item(0)->getAttribute("start"));
	$this->SCEH->updateProgressBar(51.2);
	if(trim($roots[0]) == "") {
		$roots = array();
		$roots[0] = "TEI";
	}
	foreach($roots as $root) {
// $this->DOM->save('/tmp/foo.xml');
         $start = $this->xpath->query("//tei:elementSpec[@ident='".$root."']")->item(0);
         $root_node = $this->DOM->documentElement;
	 if(!$this->verifElem($start, $root_node, array())) $schema_broken = true;
	}
	if($schema_broken) {
		$this->SCEH->sanityCheckSchemaBroken();
		return true;
	} else {
		$this->SCEH->sanityCheckSchemaOk();
		return false;
	}
}

/**
 Est-ce que tous les �l�ments sont joignables � partir des racines ?
 **/
public function pass2() {
	$res = true;
	$this->SCEH->updateProgressBar(51.5);
	foreach($this->ALL_ELEMENTS as $element) {
		if(!isset($this->COMPUTING[$element->getAttribute("ident")])) {
			$res = false;
			$this->SCEH->addError('Warning',
 $element->getAttribute("ident"), '', ' is not reachable from root');
		}
	}
	$this->SCEH->updateProgressBar(95);
	return $res;
}

/**
 *Est-ce qu'il y a des cas o� les �l�ments bouclent sur eux-m�mes
 *Un �l�ment boucle sur lui m�me si
 * - il exist dans COMPUTING
 * - il n'existe pas dans RESULTS
 * - il n'existe pas dans la liste d'erreurs
 **/
public function pass3() {
/*	$res = true;
	foreach($this->COMPUTING as $item => $valeur) {
		if(!isset($this->RESULTS[Erro$item])) {
			$existe = false;
			foreach($this->SCEH->ERRORS as $error) {
				if($error['element'] == $item) $existe = true;
			}
			if(!$existe) $this->SCEH->addError('Error', $item, '', 'is looping');
		}
	}
*/
	$this->SCEH->updateProgressBar(100);
	return $res;
}

public function showErrors() {
	$this->SCEH->showErrors_2();
}

}

?>
