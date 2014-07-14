import 'dart:html';
import 'dart:mirrors';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:paper_elements/paper_checkbox.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_fab.dart';
import 'package:paper_elements/paper_dialog.dart';
import 'package:lawndart/lawndart.dart';
//import 'package:chrome/chrome_ext.dart' as chrome;
import 'PassGen.dart';

export 'package:polymer/init.dart';

const String
  _DB_NAME         = "PassGen",
  _DB_STORE        = "state",
  _KEY_PASS_LEN    = "passLen",    
  _KEY_SECRET      = "secret",
  _KEY_SAVE_SECRET = "saveSecret",
//  _KEY_AUTO_HOST   = "autoHost",
  _KEY_USE_LOWER   = "useLower",
  _KEY_USE_UPPER   = "useUpper",
  _KEY_USE_NUMBERS = "useNumbers",
  _KEY_USE_SYMBOLS = "useSymbols";

/** TODO will lead to version compatibility issues */
final List<String> _TOP_LEVEL_DOMAINS = [
  'biz', 'com', 'edu', 'gov', 'info', 'int', 
  'mil', 'mobi', 'name', 'net', 'org', 'wiki', 'xxx'];

final HtmlElement   _subject    = querySelector('#subject');
final HtmlElement   _secret     = querySelector('#secret');       // must be HtmlElement for .shadowRoot

final HtmlElement _remsecret = querySelector('#remsecret');
//final CheckboxInputElement _fulldomain = querySelector('#fulldomain');
final HtmlElement _remsettings = querySelector('#remsettings');
final HtmlElement _sync = querySelector('#sync');
       
final HtmlElement   _upper   = querySelector('#captoggle');
final HtmlElement   _lower   = querySelector('#lowtoggle');
final HtmlElement   _numbers   = querySelector('#numtoggle');
final HtmlElement   _symbols   = querySelector('#symtoggle');

final HtmlElement   _passlength   = querySelector('#passlen');  

final HtmlElement   _passcont    = querySelector('#password');
final HtmlElement   _mainbutton  = querySelector('paper-fab');     // must be HtmlElement for selector tag (?) 

final HtmlElement    _toast       = querySelector('#toast');
final DivElement    _leftpanel   = querySelector('#leftpanel');
  

final Store _store = new Store(_DB_NAME, _DB_STORE);
final PassGen _pg = new PassGen();
int _passlen = 12;


void main() {                
  // DOM is fully loaded.
  _passcont.style.display = 'none';
  
  initPolymer().run(() {
    // code here works most of the time
    Polymer.onReady.then((_) {     
      // some things must wait until onReady callback is called
      // for an example look at the discussion linked below
      
        _getShadowInput(_secret).attributes['type'] = 'password';  
        
        _loadState();      
           
        _getShadowInput(_subject).focus();
    });
  });  
}  

void _setListeners() {
  _lower.onClick.listen((e) => _toggleActive(_lower, _KEY_USE_LOWER));
  _upper.onClick.listen((e) => _toggleActive(_upper, _KEY_USE_UPPER));
  _numbers.onClick.listen((e) => _toggleActive(_numbers, _KEY_USE_NUMBERS));
  _symbols.onClick.listen((e) => _toggleActive(_symbols, _KEY_USE_SYMBOLS));
  
  
  _mainbutton.onClick.listen((e) {
    if (_passcont.style.display == 'none') {
      String pass = _generatePassword();
      _passcont.style.display = 'flex';
      _passcont.attributes['inputValue'] = pass;
      _mainbutton.attributes['icon'] = 'chevron-left';
      window.getSelection().selectAllChildren(_getShadowInput(_passcont));
    } else {
      _passcont.style.display = 'none';
      _passcont.attributes['InputValue'] = '';
      _mainbutton.attributes['icon'] = 'chevron-right';
    }
  });
  
  _remsecret.onChange.listen((e) => _store.open().then((_) {
    bool checked = _isChecked(_remsecret);
    _store.save(checked.toString(), _KEY_SAVE_SECRET);
    if (checked) {
      _doSaveSecret();
    } else {
      _store.removeByKey(_KEY_SECRET);
    }
  }));
  
  // TODO remsettings, sync
  
  
  
  _passlength.onClick.listen((e) => _store.open().then((_) {
    String s = _passlength.shadowRoot.querySelector('#sliderKnobInner').attributes['value'];
    _store.save(s, _KEY_PASS_LEN);
    _passlen = int.parse(s);
  }));
}

String _generatePassword() {  
  _saveState();
  
  int charTypes = 0;
  if (_isActive(_lower)) charTypes |= PassGen.CHAR_LOWER;
  if (_isActive(_upper)) charTypes |= PassGen.CHAR_UPPER;
  if (_isActive(_numbers)) charTypes |= PassGen.CHAR_NUMBERS;
  if (_isActive(_symbols)) charTypes |= PassGen.CHAR_SYMBOLS;
  
  var map1 = _subject.attributes;
  var map2 = _getShadowInput(_subject).attributes;
 
  String subject = map2['value'];
  String secret =  _secret.attributes['inputValue'];
  return _pg.hashAndConvert(subject + secret, _passlen, charTypes);
}
  


void _doSaveSecret() {
  String s = _getShadowInput(_secret).attributes['value'];
  if (s == null) {
//    _store.removeByKey(_KEY_SECRET);  TODO wait til save is working
  } else {
    _store.save(_pg.cipher(s, true), _KEY_SECRET);
  }
}


void _saveState() {
  _store.open()
    .then((_) => _store.nuke())
    .then((_) => _store.save(_passlength.shadowRoot.querySelector('#sliderKnobInner').attributes['value'], _KEY_PASS_LEN))
    .then((_) => _store.save(_isChecked(_remsecret).toString(), _KEY_SAVE_SECRET))
    .then((_) => _store.save(_isActive(_lower).toString(), _KEY_USE_LOWER))
    .then((_) => _store.save(_isActive(_upper).toString(), _KEY_USE_UPPER))
    .then((_) => _store.save(_isActive(_numbers).toString(), _KEY_USE_NUMBERS))
    .then((_) => _store.save(_isActive(_symbols).toString(), _KEY_USE_SYMBOLS))
//    .then((_) => _store.save(_autoHost.checked.toString(), _KEY_AUTO_HOST))
    .then((_) {
      if (_isChecked(_remsecret) && _store.isOpen) {
        _doSaveSecret();
      }
    });
}

void _loadState() {
  _store.open()
    .then((_) => _store.getByKey(_KEY_PASS_LEN))
    .then((value) {
      if (value != null) {
        _passlen = int.parse(value);
        _passlength.attributes['value'] = _passlen.toString();
      }
    })
//    .then((_) => _addLengthOptions())
    .then((_) => _store.getByKey(_KEY_USE_LOWER))
    .then((value) {
      if (value != null) _setActive(_lower, value == true.toString());
    })
    .then((_) => _store.getByKey(_KEY_USE_UPPER))
    .then((value) {
      if (value != null) _setActive(_upper, value == true.toString());
    })
    .then((_) => _store.getByKey(_KEY_USE_NUMBERS))
    .then((value) {
      if (value != null) _setActive(_numbers, value == true.toString());
    })
    .then((_) => _store.getByKey(_KEY_USE_SYMBOLS))
    .then((value) {
      if (value != null) _setActive(_symbols, value == true.toString());
    })
//    .then((_) => _store.getByKey(_KEY_AUTO_HOST))
//    .then((value) {
//      if (value != null) _autoHost.checked = value == true.toString();
//    })
    .then((_) => _store.getByKey(_KEY_SAVE_SECRET))
    .then((value) {      
      if (value != null) _setChecked(_remsecret, value == true.toString());
      if (_isChecked(_remsecret)) {
        _store.getByKey(_KEY_SECRET)
          .then((value) {
            if (value != null) _getShadowInput(_secret).attributes['value'] ='asdfa99999';// _pg.cipher(value, false);
        });
      }
    })
    
    /*
     * Workaround timing issue
     */
    .then((_) => _setListeners());
}










HtmlElement _getShadowInput(HtmlElement e) {
  return e.shadowRoot.olderShadowRoot.children.firstWhere((el) => el.id == 'input');
}



bool _isChecked(Element e) {
  return e.attributes.containsKey('checked');
}

void _setChecked(Element e, bool checked) {
  if (checked) {
    e.attributes['checked'] = 'true';   
  } else {
    e.attributes.remove('checked'); 
  }  
}


bool _isActive(Element e) {
  return !e.attributes.containsKey('inactive');
}

void _setActive(Element e, bool active) {
  if (active) {
    e.attributes.remove('inactive');
  } else {
    e.attributes['inactive'] = 'true';
  }  
}

/* 
 * NOTE: only to be used in response to user action
 */
void _toggleActive(Element e, String key) {
  _setActive(e, !_isActive(e));   
  _store.open().then((_) => _store.save(_isActive(e).toString(), key));
}

//
//void _toggleOpened(Element e) {
//  if (e.attributes['opened'] == 'true') {
//    e.attributes.remove('opened');
//  } else {
//    e.attributes['opened'] = 'true';
//  }
//}
//
//void _toggleDisplay(Element e) {
//  if (e.style.display == 'none') {
//    e.style.display = 'flex';
//  } else {
//    e.style.display = 'none';
//  }
//}
//
//void _toggleLeftRight(Element e) {
//  if (e.attributes['icon'] == 'chevron-right') {
//    e.attributes['icon'] = 'chevron-left';
//  } else {
//    e.attributes['icon'] = 'chevron-right';
//  }
//}