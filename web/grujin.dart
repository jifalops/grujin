import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:paper_elements/paper_checkbox.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_fab.dart';
import 'package:paper_elements/paper_dialog.dart';

export 'package:polymer/init.dart';

const String
  _DB_NAME         = "PassGen",
  _DB_STORE        = "state",
  _KEY_PASS_LEN    = "passLen",    
  _KEY_SECRET      = "secret",
  _KEY_SAVE_SECRET = "saveSecret",
  _KEY_AUTO_HOST   = "autoHost",
  _KEY_USE_LOWER   = "useLower",
  _KEY_USE_UPPER   = "useUpper",
  _KEY_USE_NUMBERS = "useNumbers",
  _KEY_USE_SYMBOLS = "useSymbols";

/** TODO will lead to version compatibility issues */
final List<String> _TOP_LEVEL_DOMAINS = [
  'biz', 'com', 'edu', 'gov', 'info', 'int', 
  'mil', 'mobi', 'name', 'net', 'org', 'wiki', 'xxx'];

final PaperInput    _subject    = querySelector('#subject');
final HtmlElement   _secret     = querySelector('#secret');       // must be HtmlElement for .shadowRoot

final PaperCheckbox _remsecret = querySelector('#remsecret');
final PaperCheckbox _fulldomain = querySelector('#fulldomain');
final PaperCheckbox _remsettings = querySelector('#remsettings');
final PaperCheckbox _sync = querySelector('#sync');
       
final HtmlElement   _captoggle   = querySelector('#captoggle');
final HtmlElement   _lowtoggle   = querySelector('#lowtoggle');
final HtmlElement   _numtoggle   = querySelector('#numtoggle');
final HtmlElement   _symtoggle   = querySelector('#symtoggle');  

final HtmlElement   _passcont    = querySelector('#password');
final HtmlElement   _mainbutton  = querySelector('paper-fab');     // must be HtmlElement for selector tag (?) 

final PaperToast    _toast       = querySelector('#toast');
final DivElement    _leftpanel   = querySelector('#leftpanel');
  
void main() {                
  // DOM is fully loaded.
  _passcont.style.display = 'none';
  
  initPolymer().run(() {
    // code here works most of the time
    Polymer.onReady.then((_) {     
      // some things must wait until onReady callback is called
      // for an example look at the discussion linked below
    });
  });
  
  InputElement input = _secret.shadowRoot.olderShadowRoot.children.firstWhere((el) => el.id == 'input');
  input.type = 'password';
  
  _captoggle.onClick.listen((e) => _toggleActive(_captoggle));
  _lowtoggle.onClick.listen((e) => _toggleActive(_lowtoggle));
  _numtoggle.onClick.listen((e) => _toggleActive(_numtoggle));
  _symtoggle.onClick.listen((e) => _toggleActive(_symtoggle));
  
  _mainbutton.onClick.listen((e) {
    _toggleDisplay(_passcont);
    _toggleLeftRight(_mainbutton);
  });
//  _passdialog.onBlur.listen((e) => _passdialog.attributes.remove('opened'));
}  

void _toggleActive(Element e) {
  if (e.attributes.containsKey('inactive')) {
    e.attributes.remove('inactive');  
  } else {
    e.attributes['inactive'] = 'true';
  }
}

void _toggleOpened(Element e) {
  if (e.attributes['opened'] == 'true') {
    e.attributes.remove('opened');
  } else {
    e.attributes['opened'] = 'true';
  }
}

void _toggleDisplay(Element e) {
  if (e.style.display == 'none') {
    e.style.display = 'flex';
  } else {
    e.style.display = 'none';
  }
}

void _toggleLeftRight(Element e) {
  if (e.attributes['icon'] == 'chevron-right') {
    e.attributes['icon'] = 'chevron-left';
  } else {
    e.attributes['icon'] = 'chevron-right';
  }
}
  