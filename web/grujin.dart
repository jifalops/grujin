import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:paper_elements/paper_checkbox.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_fab.dart';

export 'package:polymer/init.dart';

final PaperInput    _subject    = querySelector('#subject');
final HtmlElement   _secret     = querySelector('#secret');       // must be HtmlElement for .shadowRoot


final PaperCheckbox _remsecret = querySelector('#remsecret');
final PaperCheckbox _rempassoptions = querySelector('#rempassoptions');



final DivElement    _leftpanel = querySelector('#leftpanel');
final PaperToast    _toast      = querySelector('#toast');       
final HtmlElement   _mainbutton = querySelector('paper-fab');     // must be HtmlElement for selector tag (?) 
final HtmlElement   _captoggle   = querySelector('#captoggle');
final HtmlElement   _lowtoggle   = querySelector('#lowtoggle');
final HtmlElement   _numtoggle   = querySelector('#numtoggle');
final HtmlElement   _symtoggle   = querySelector('#symtoggle');  
  
void main() {                
  // DOM is fully loaded. 
  InputElement input = _secret.shadowRoot.olderShadowRoot.children.firstWhere((el) => el.id == 'input');
  input.type = 'password';
  
  _captoggle.onClick.listen((e) => _toggleActive(_captoggle));
  _lowtoggle.onClick.listen((e) => _toggleActive(_lowtoggle));
  _numtoggle.onClick.listen((e) => _toggleActive(_numtoggle));
  _symtoggle.onClick.listen((e) => _toggleActive(_symtoggle));
}  

void _toggleActive(Element e) {
  if (e.attributes.containsKey('inactive')) {
    e.attributes.remove('inactive');  
  } else {
    e.attributes['inactive'] = 'true';
  }
}
  