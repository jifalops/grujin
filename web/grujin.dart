import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_toast.dart';
import 'package:paper_elements/paper_checkbox.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_fab.dart';
import 'package:paper_elements/paper_slider.dart';
import 'package:lawndart/lawndart.dart';
import 'PassGen.dart';

export 'package:polymer/init.dart';

const int 
  DEFAULT_PASS_LEN = 12,
  SUBJECT_MIN_LEN = 3,
  SECRET_MIN_LEN = 4;

const String
  _DB_NAME         = "PassGen",
  _DB_STORE        = "state",
  _KEY_PASS_LEN    = "passLen",    
  _KEY_SECRET      = "secret",
  _KEY_SAVE_SECRET = "saveSecret",
  _KEY_USE_LOWER   = "useLower",
  _KEY_USE_UPPER   = "useUpper",
  _KEY_USE_NUMBERS = "useNumbers",
  _KEY_USE_SYMBOLS = "useSymbols";

PaperInput    _subject;
PaperInput    _secret;
PaperCheckbox _remsecret;
PaperCheckbox _remsettings;
PaperCheckbox _sync;       
PaperButton   _upper;
PaperButton   _lower;
PaperButton   _numbers;
PaperButton   _symbols;
PaperSlider   _passlen;  
PaperInput    _passcont;
PaperFab      _mainbutton; 
PaperToast    _toast;

final Store _store = new Store(_DB_NAME, _DB_STORE);
final PassGen _pg = new PassGen();

void main() {                
  // DOM is fully loaded (but not polymer necessarily).     
  initPolymer().run(() {  
    // polymer mostly ready (most code works).
    Polymer.onReady.then((_) {
      // Ready!
      _subject     = querySelector('#subject');
      _secret      = querySelector('#secret');      
      _remsecret   = querySelector('#remsecret');
      _remsettings = querySelector('#remsettings');
      _sync        = querySelector('#sync');             
      _upper       = querySelector('#captoggle');
      _lower       = querySelector('#lowtoggle');
      _numbers     = querySelector('#numtoggle');
      _symbols     = querySelector('#symtoggle');
      _passlen     = querySelector('#passlen');  
      _passcont    = querySelector('#password');
      _mainbutton  = querySelector('paper-fab'); 
      _toast       = querySelector('#toast');     
      
      // Using this instead of hidden because it is also display:none in css,
      // and setting e.hidden=false doesn't show it.
      _passcont.style.display = 'none';
      
      _getShadowInput(_secret).type = 'password';
      
      _loadState().then((_) => _setListeners()); 
    });
  });  
}  

Future _loadState() {
  return _store.open().then((_) => 
    _store.getByKey(_KEY_PASS_LEN)).then((value) {
      if (value is num) {
        _passlen.value = value;
      } else {
        _passlen.value = DEFAULT_PASS_LEN;
      }
    }).then((_) => 
    _store.getByKey(_KEY_USE_LOWER)).then((value) {
      if (value != null) _setActive(_lower, value == true);
    }).then((_) => 
    _store.getByKey(_KEY_USE_UPPER)).then((value) {
      if (value != null) _setActive(_upper, value == true);
    }).then((_) => 
    _store.getByKey(_KEY_USE_NUMBERS)).then((value) {
      if (value != null) _setActive(_numbers, value == true);
    }).then((_) => 
    _store.getByKey(_KEY_USE_SYMBOLS)).then((value) {
      if (value != null) _setActive(_symbols, value == true);
    }).then((_) => 
    _store.getByKey(_KEY_SAVE_SECRET)).then((value) {      
      if (value != null) _remsecret.checked = value == true;
      if (_remsecret.checked) {
        _store.getByKey(_KEY_SECRET).then((value) {
          if (value != null) _secret.value = _pg.cipher(value, false);
        });
      }
      _updatePassword();
    });  
}


void _saveState() {
  _store.open()
    .then((_) => _store.nuke())
    .then((_) => _store.save(_passlen.immediateValue, _KEY_PASS_LEN))
    .then((_) => _store.save(_remsecret.checked, _KEY_SAVE_SECRET))
    .then((_) => _store.save(_isActive(_lower), _KEY_USE_LOWER))
    .then((_) => _store.save(_isActive(_upper), _KEY_USE_UPPER))
    .then((_) => _store.save(_isActive(_numbers), _KEY_USE_NUMBERS))
    .then((_) => _store.save(_isActive(_symbols), _KEY_USE_SYMBOLS))
    .then((_) {
      if (_remsecret.checked && _store.isOpen) {
        _doSaveSecret();
      }
    });
}

void _setListeners() {
  _lower.onClick.listen((e) { _toggleActive(_lower, _KEY_USE_LOWER); _updatePassword(); });
  _upper.onClick.listen((e) { _toggleActive(_upper, _KEY_USE_UPPER); _updatePassword(); });
  _numbers.onClick.listen((e) { _toggleActive(_numbers, _KEY_USE_NUMBERS); _updatePassword(); });
  _symbols.onClick.listen((e) { _toggleActive(_symbols, _KEY_USE_SYMBOLS); _updatePassword(); });
    
  _mainbutton.onClick.listen((e) {
    if (!_isActive(_mainbutton)) return;
    if (_passcont.style.display == 'none') {
      _saveState();
      String pass = _generatePassword();
      _passcont.style.display = 'flex';
      _passcont.value = pass;
      _mainbutton.icon = 'chevron-left';
      window.getSelection().selectAllChildren(_getShadowInput(_passcont)); //TODO doesn't highlight text
    } else {
      _passcont.style.display = 'none';
      _passcont.value = '';
      _mainbutton.icon = 'chevron-right';
    }
  });
  
  _remsecret.onChange.listen((e) => _store.open().then((_) {    
    _store.save(_remsecret.checked, _KEY_SAVE_SECRET);
    if (_remsecret.checked) {
      _doSaveSecret();
    } else {
      _store.removeByKey(_KEY_SECRET);
    }
  }));
  
  // TODO remsettings, sync
  
    
  _passlen.onChange.listen((e) {
    _updatePassword();
    _store.open().then((_) {       
      _store.save(_passlen.immediateValue, _KEY_PASS_LEN);
    });
  });
  
  
  // text inputs control action button
  _subject.onKeyDown.listen((e) {
    _updatePassword();    
  });
  _secret.onKeyDown.listen((e) {
    _updatePassword();
    _doSaveSecret();
  });
  _subject.onKeyUp.listen((e) {
    _updatePassword();
  });
  _secret.onKeyUp.listen((e) {
    _updatePassword();
    _doSaveSecret();
  });  
  
  _getShadowInput(_subject).focus();
}


// TODO rename this and don't evaluate on every change.
void _updatePassword() {
  if (_canSubmit()) {    
    _setActive(_mainbutton, true);
    String pass = _generatePassword();
    _passcont.style.display = 'flex';
    _passcont.value = pass;
    _mainbutton.icon = 'chevron-left';    
  } else {
    _setActive(_mainbutton, false);
    _passcont.style.display = 'none';
    _passcont.value = '';
    _mainbutton.icon = 'chevron-right';
  }
  
}

bool _canSubmit() {
  return _subject.inputValue.length >= SUBJECT_MIN_LEN 
      && _secret.inputValue.length >= SECRET_MIN_LEN;
}

String _generatePassword() {   
  int charTypes = 0;
  if (_isActive(_lower)) charTypes |= PassGen.CHAR_LOWER;
  if (_isActive(_upper)) charTypes |= PassGen.CHAR_UPPER;
  if (_isActive(_numbers)) charTypes |= PassGen.CHAR_NUMBERS;
  if (_isActive(_symbols)) charTypes |= PassGen.CHAR_SYMBOLS;  
  return _pg.hashAndConvert((_subject.inputValue + _secret.inputValue), _passlen.immediateValue, charTypes);  
}

void _doSaveSecret() {
  if (_remsecret.checked && _canSubmit()) {
    _store.save(_pg.cipher(_secret.inputValue, true), _KEY_SECRET);
  }
}





// helper function to get <input> from within <paper-input>
InputElement _getShadowInput(HtmlElement e) {
  return e.shadowRoot.olderShadowRoot.querySelector('input');
}

// Using 'inactive' attribute to style character toggle buttons.
bool _allowInactive(Element e) {  
  if (e == _lower) {
    return _isActive(_upper) || _isActive(_numbers) || _isActive(_symbols);  
  } else if (e == _upper) {
    return _isActive(_lower) || _isActive(_numbers) || _isActive(_symbols);  
  } else if (e == _numbers) {
    return _isActive(_lower) || _isActive(_upper) || _isActive(_symbols);  
  } else if (e == _symbols) {
    return _isActive(_lower) || _isActive(_upper) || _isActive(_numbers);  
  }
  return true;
}

bool _isActive(Element e) {
  return !e.attributes.containsKey('inactive');
}

void _setActive(Element e, bool active) {
  if (active) {
    e.attributes.remove('inactive');
  } else {
    if (_allowInactive(e)) e.attributes['inactive'] = 'true';
  }  
}

// NOTE: only to be used in response to user action (since it stores the change).
void _toggleActive(Element e, String key) {
  _setActive(e, !_isActive(e));   
  _store.open().then((_) => _store.save(_isActive(e), key));
}



//bool _isChecked(Element e) {
//  return e.attributes.containsKey('checked');
//}
//
//void _setChecked(Element e, bool checked) {
//  if (checked) {
//    e.attributes['checked'] = 'true';   
//  } else {
//    e.attributes.remove('checked'); 
//  }  
//}
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