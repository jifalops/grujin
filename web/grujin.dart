import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_toast.dart';
//import 'package:paper_elements/paper_item.dart';
import 'package:paper_elements/paper_checkbox.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_fab.dart';
import 'package:paper_elements/paper_slider.dart';
import 'package:lawndart/lawndart.dart';
import 'PassGen.dart';
import 'package:chrome/chrome_ext.dart' as chrome;

export 'package:polymer/init.dart';

const int 
  _SUBJECT_MIN_LEN = 3,
  _SECRET_MIN_LEN = 4;

const String
  _DB_NAME            = "PaperSafe",
  _DB_STORE_SETTINGS  = "settings",
  _DB_STORE_SUBJECTS  = "subjects", 
  _KEY_PASS_LEN       = "passLen",  
  _KEY_SECRET         = "secret",
  _KEY_SAVE_SECRET    = "saveSecret",
  _KEY_SAVE_SETTINGS  = "saveSettings",
  _KEY_SYNC_SETTINGS  = "syncSettings",
  _KEY_USE_LOWER      = "useLower",
  _KEY_USE_UPPER      = "useUpper",
  _KEY_USE_NUMBERS    = "useNumbers",
  _KEY_USE_SYMBOLS    = "useSymbols";

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

final Store _statestore = new Store(_DB_NAME, _DB_STORE_SETTINGS);
final Store _subjectstore = new Store(_DB_NAME, _DB_STORE_SUBJECTS);
final PassGen _pg = new PassGen();

final List<String> _TLD = [
  'com', 'org', 'net', 'int', 'edu', 'gov', 'mil',
  'biz', 'info', 'mobi', 'name', 'wiki', 'xxx'
];

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
      _sync.disabled = true;      
      
      _loadState().then((_) {
        _updateSubmitButton();    
        _setListeners();
      });        
    }); 
  });  
}  

Future _saveState() {
  return _statestore.open()
    .then((_) => _statestore.nuke())
    .then((_) => _statestore.save(_remsecret.checked, _KEY_SAVE_SECRET))
    .then((_) => _doSaveSecret())          
    .then((_) => _statestore.save(_remsettings.checked, _KEY_SAVE_SETTINGS))
    .then((_) => _savePassOptions())
    .then((_) => _statestore.save(_sync.checked, _KEY_SYNC_SETTINGS));
}

void _savePassOptions() {
  if (!_remsettings.checked || _subject.inputValue.length < _SUBJECT_MIN_LEN) return;
  var opts = new Map<String, dynamic>(); 
  opts[_KEY_PASS_LEN] = _passlen.immediateValue;
  opts[_KEY_USE_LOWER] = _isActive(_lower);
  opts[_KEY_USE_UPPER] = _isActive(_upper);
  opts[_KEY_USE_NUMBERS] = _isActive(_numbers);
  opts[_KEY_USE_SYMBOLS] = _isActive(_symbols);      
  _subjectstore.open().then((_) => 
     _subjectstore.save(new JsonCodec().encode(opts), _subject.inputValue));  
}

Future _loadState() {
  _loadSubject();
  return _statestore.open().then((_) =>
    _statestore.getByKey(_KEY_SAVE_SECRET)).then((value) {      
      if (value != null) _remsecret.checked = value;
      if (_remsecret.checked) {
        _statestore.getByKey(_KEY_SECRET).then((value) {
          if (value != null) _secret.value = _pg.cipher(value, false);
        });
      }}).then((_) =>     
    _statestore.getByKey(_KEY_SYNC_SETTINGS)).then((value) {
      if (value != null) _sync.checked = value;
      _syncSettings();     
  }).then((_) =>
    _statestore.getByKey(_KEY_SAVE_SETTINGS)).then((value) {
        if (value != null) _remsettings.checked = value;
        _loadPassOptions();      
    });        
}



void _loadPassOptions() {
  if (!_remsettings.checked) return;
  _subjectstore.open().then((_) => 
    _subjectstore.getByKey(_subject.inputValue).then((value) {
      if (value != null) {
        Map opts = new JsonCodec().decode(value);
        _passlen.value = opts[_KEY_PASS_LEN];
        _setActive(_lower, opts[_KEY_USE_LOWER]);
        _setActive(_upper, opts[_KEY_USE_UPPER]);
        _setActive(_numbers, opts[_KEY_USE_NUMBERS]);
        _setActive(_symbols, opts[_KEY_USE_SYMBOLS]);
      }
    })
  );   
}

// for the chrome extension
void _loadSubject() {
  var params = new chrome.TabsQueryParams()
    ..active = true
    ..currentWindow = true;
  chrome.tabs.query(params).then((tabs) {   
    String host = Uri.parse(tabs[0].url).host; 
    var parts = host.split('.');
    var len = parts.length;    
    if (len > 2) {
      int offset = 3;
      if (_TLD.contains(parts.last)) {
        offset = 2;
      }      
      host = parts.getRange(len - offset, len).join('.');       
    }
    _subject.value = host;
  });
}

void _syncSettings() {
  if (!_sync.checked || !_remsettings.checked) return;
  // TODO chrome sync
}


//String _encodeSubject() {
//  return new String.fromCharCodes(new Utf8Codec().encode(_subject.inputValue));
//}


void _setListeners() {   
  _mainbutton.onClick.listen((e) {
    if (!_isActive(_mainbutton)) return;
    if (_passcont.style.display == 'none') {
      _saveState();
      String pass = _generatePassword();
      _passcont.style.display = 'flex';
      _passcont.value = pass;
      _mainbutton.icon = 'chevron-left';
      window.getSelection().selectAllChildren(_getShadowInput(_passcont));        //TODO doesn't highlight text
    } else {
      _passcont.style.display = 'none';
      _passcont.value = '';
      _mainbutton.icon = 'chevron-right';
    }
  });
  
  _lower.onClick.listen((e) => _toggleActive(_lower, _KEY_USE_LOWER));
  _upper.onClick.listen((e) => _toggleActive(_upper, _KEY_USE_UPPER));
  _numbers.onClick.listen((e) => _toggleActive(_numbers, _KEY_USE_NUMBERS));
  _symbols.onClick.listen((e) => _toggleActive(_symbols, _KEY_USE_SYMBOLS));
  
  _remsecret.onClick.listen((e) => _statestore.open().then((_) {    
    _statestore.save(_remsecret.checked, _KEY_SAVE_SECRET);
    _doSaveSecret();
  }));
  
  _remsettings.onClick.listen((e) => _statestore.open().then((_) {    
    _statestore.save(_remsettings.checked, _KEY_SAVE_SETTINGS).then((_) {
      if (_remsettings.checked) {
        //_sync.disabled = false;      
      } else {
        //_sync.checked = false;
        //_sync.disabled = true;
      }
    });
  }));
  
  
  _sync.onClick.listen((e) => _statestore.open().then((_) {    
      _statestore.save(_sync.checked, _KEY_SYNC_SETTINGS);
      _syncSettings();      
  }));
  
  
  // Change checkboxes when clicking on the words next to it
  // not using because it causes double events and checkbox will check,uncheck quickly if it is clicked
//  querySelector('#overflow').querySelectorAll('paper-item').forEach((elem) =>
//    elem.onClick.listen((event) {
//      PaperCheckbox pc = elem.querySelector('paper-checkbox');
//      if (!pc.disabled) {
//        pc.checked = !pc.checked;
//      }
//  }));
    
  
  // Not needed (for now)
//  _passlen.onChange.listen((e) {
//    _statestore.open().then((_) {       
//      _statestore.save(_passlen.immediateValue, _KEY_PASS_LEN);
//    });
//  });
  
  
  // text inputs control action button
  _subject.onKeyDown.listen((e) {
    _loadPassOptions();
    _updateSubmitButton();    
  });
  _secret.onKeyDown.listen((e) {
    _updateSubmitButton();
  });
  _subject.onKeyUp.listen((e) {
    _loadPassOptions();
    _updateSubmitButton();
  });
  _secret.onKeyUp.listen((e) {
    _updateSubmitButton();
  });  
  
  _getShadowInput(_subject).focus();
}

void _updateSubmitButton() {
  _setActive(_mainbutton, _canSubmit());
}

bool _canSubmit() {
  return _subject.inputValue.length >= _SUBJECT_MIN_LEN 
      && _secret.inputValue.length >= _SECRET_MIN_LEN;
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
    _statestore.save(_pg.cipher(_secret.inputValue, true), _KEY_SECRET);
  } else if (!_remsecret.checked) {
    _statestore.removeByKey(_KEY_SECRET);
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

void _toggleActive(Element e, String key) {
  _setActive(e, !_isActive(e));   
//  _statestore.open().then((_) => _statestore.save(_isActive(e), key));
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