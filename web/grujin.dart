import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:paper_elements/paper_checkbox.dart';
import 'package:paper_elements/paper_fab.dart';

export 'package:polymer/init.dart';

const int _INDEX_LETTERS  = -1; //unused
const int _INDEX_UPPER   = 0;
const int _INDEX_LOWER   = 1;
const int _INDEX_NUMBERS = 2;
const int _INDEX_SYMBOLS = 3;

final PaperInput    _subject    = querySelector('#subject');
final HtmlElement   _secret     = querySelector('#secret');       // must be HtmlElement for .shadowRoot


final PaperCheckbox _remsecret = querySelector('#remsecret');
final PaperCheckbox _rempassoptions = querySelector('#rempassoptions');



final DivElement    _leftpanel = querySelector('#leftpanel');
final PaperToast    _toast      = querySelector('#toast');       
final HtmlElement   _mainbutton = querySelector('paper-fab');     // must be HtmlElement for selector tag (?) 

void main() {                
  // DOM is fully loaded. 
  InputElement input = _secret.shadowRoot.olderShadowRoot.children.firstWhere((el) => el.id == 'input');
  input.type = 'password';
 
}  
  