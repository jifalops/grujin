library app_bootstrap;

import 'package:polymer/polymer.dart';

import 'package:core_elements/core_toolbar.dart' as i0;
import 'package:core_elements/core_selection.dart' as i1;
import 'package:core_elements/core_selector.dart' as i2;
import 'package:core_elements/core_menu.dart' as i3;
import 'package:core_elements/core_meta.dart' as i4;
import 'package:core_elements/core_iconset.dart' as i5;
import 'package:core_elements/core_icon.dart' as i6;
import 'package:core_elements/core_item.dart' as i7;
import 'package:core_elements/core_header_panel.dart' as i8;
import 'package:core_elements/core_media_query.dart' as i9;
import 'package:core_elements/core_drawer_panel.dart' as i10;
import 'package:core_elements/core_icons.dart' as i11;
import 'package:paper_elements/paper_focusable.dart' as i12;
import 'package:paper_elements/paper_ripple.dart' as i13;
import 'package:paper_elements/paper_shadow.dart' as i14;
import 'package:paper_elements/paper_button.dart' as i15;
import 'package:paper_elements/paper_icon_button.dart' as i16;
import 'package:paper_elements/paper_radio_button.dart' as i17;
import 'package:paper_elements/paper_checkbox.dart' as i18;
import 'package:core_elements/core_input.dart' as i19;
import 'package:paper_elements/paper_input.dart' as i20;
import 'package:core_elements/core_transition.dart' as i21;
import 'package:core_elements/core_key_helper.dart' as i22;
import 'package:core_elements/core_overlay_layer.dart' as i23;
import 'package:core_elements/core_overlay.dart' as i24;
import 'package:core_elements/core_transition_css.dart' as i25;
import 'package:paper_elements/paper_toast.dart' as i26;
import 'package:core_elements/core_range.dart' as i27;
import 'package:paper_elements/paper_progress.dart' as i28;
import 'package:paper_elements/paper_slider.dart' as i29;
import 'package:paper_elements/paper_fab.dart' as i30;
import 'package:paper_elements/paper_item.dart' as i31;
import 'package:core_elements/web_animations.dart' as i32;
import 'package:paper_elements/paper_menu_button_overlay.dart' as i33;
import 'package:paper_elements/paper_menu_button_transition.dart' as i34;
import 'package:paper_elements/paper_menu_button.dart' as i35;
import 'package:paper_elements/roboto.dart' as i36;
import 'grujin.dart' as i37;
import 'package:smoke/smoke.dart' show Declaration, PROPERTY, METHOD;
import 'package:smoke/static.dart' show useGeneratedCode, StaticConfiguration;

void main() {
  useGeneratedCode(new StaticConfiguration(
      checkedMode: false,
      getters: {
        #$: (o) => o.$,
        #bardown: (o) => o.bardown,
        #blurAction: (o) => o.blurAction,
        #checkboxAnimationEnd: (o) => o.checkboxAnimationEnd,
        #checked: (o) => o.checked,
        #container: (o) => o.container,
        #contextMenuAction: (o) => o.contextMenuAction,
        #disabled: (o) => o.disabled,
        #dismiss: (o) => o.dismiss,
        #downAction: (o) => o.downAction,
        #editable: (o) => o.editable,
        #error: (o) => o.error,
        #expandKnob: (o) => o.expandKnob,
        #focusAction: (o) => o.focusAction,
        #halign: (o) => o.halign,
        #icon: (o) => o.icon,
        #iconSrc: (o) => o.iconSrc,
        #immediateValue: (o) => o.immediateValue,
        #inputChange: (o) => o.inputChange,
        #inputChangeAction: (o) => o.inputChangeAction,
        #inputValue: (o) => o.inputValue,
        #invalid: (o) => o.invalid,
        #keydown: (o) => o.keydown,
        #knobTransitionEnd: (o) => o.knobTransitionEnd,
        #label: (o) => o.label,
        #markers: (o) => o.markers,
        #max: (o) => o.max,
        #min: (o) => o.min,
        #mode: (o) => o.mode,
        #multi: (o) => o.multi,
        #multiline: (o) => o.multiline,
        #narrowMode: (o) => o.narrowMode,
        #opened: (o) => o.opened,
        #overlay: (o) => o.overlay,
        #overlayBg: (o) => o.overlayBg,
        #pin: (o) => o.pin,
        #placeholder: (o) => o.placeholder,
        #queryMatches: (o) => o.queryMatches,
        #raisedButton: (o) => o.raisedButton,
        #ratio: (o) => o.ratio,
        #resetKnob: (o) => o.resetKnob,
        #responsiveWidth: (o) => o.responsiveWidth,
        #rows: (o) => o.rows,
        #scroll: (o) => o.scroll,
        #secondaryProgress: (o) => o.secondaryProgress,
        #secondaryRatio: (o) => o.secondaryRatio,
        #selected: (o) => o.selected,
        #selectionSelect: (o) => o.selectionSelect,
        #slow: (o) => o.slow,
        #snaps: (o) => o.snaps,
        #src: (o) => o.src,
        #tapAction: (o) => o.tapAction,
        #text: (o) => o.text,
        #togglePanel: (o) => o.togglePanel,
        #tokenList: (o) => o.tokenList,
        #track: (o) => o.track,
        #trackEnd: (o) => o.trackEnd,
        #trackStart: (o) => o.trackStart,
        #transition: (o) => o.transition,
        #transitionEndAction: (o) => o.transitionEndAction,
        #upAction: (o) => o.upAction,
        #value: (o) => o.value,
        #z: (o) => o.z,
      },
      setters: {
        #container: (o, v) { o.container = v; },
        #disabled: (o, v) { o.disabled = v; },
        #halign: (o, v) { o.halign = v; },
        #icon: (o, v) { o.icon = v; },
        #iconSrc: (o, v) { o.iconSrc = v; },
        #immediateValue: (o, v) { o.immediateValue = v; },
        #inputValue: (o, v) { o.inputValue = v; },
        #max: (o, v) { o.max = v; },
        #min: (o, v) { o.min = v; },
        #multi: (o, v) { o.multi = v; },
        #narrowMode: (o, v) { o.narrowMode = v; },
        #opened: (o, v) { o.opened = v; },
        #overlay: (o, v) { o.overlay = v; },
        #overlayBg: (o, v) { o.overlayBg = v; },
        #queryMatches: (o, v) { o.queryMatches = v; },
        #secondaryProgress: (o, v) { o.secondaryProgress = v; },
        #selected: (o, v) { o.selected = v; },
        #src: (o, v) { o.src = v; },
        #z: (o, v) { o.z = v; },
      },
      names: {
        #$: r'$',
        #bardown: r'bardown',
        #blurAction: r'blurAction',
        #checkboxAnimationEnd: r'checkboxAnimationEnd',
        #checked: r'checked',
        #container: r'container',
        #contextMenuAction: r'contextMenuAction',
        #disabled: r'disabled',
        #dismiss: r'dismiss',
        #downAction: r'downAction',
        #editable: r'editable',
        #error: r'error',
        #expandKnob: r'expandKnob',
        #focusAction: r'focusAction',
        #halign: r'halign',
        #icon: r'icon',
        #iconSrc: r'iconSrc',
        #immediateValue: r'immediateValue',
        #inputChange: r'inputChange',
        #inputChangeAction: r'inputChangeAction',
        #inputValue: r'inputValue',
        #invalid: r'invalid',
        #keydown: r'keydown',
        #knobTransitionEnd: r'knobTransitionEnd',
        #label: r'label',
        #markers: r'markers',
        #max: r'max',
        #min: r'min',
        #mode: r'mode',
        #multi: r'multi',
        #multiline: r'multiline',
        #narrowMode: r'narrowMode',
        #opened: r'opened',
        #overlay: r'overlay',
        #overlayBg: r'overlayBg',
        #pin: r'pin',
        #placeholder: r'placeholder',
        #queryMatches: r'queryMatches',
        #raisedButton: r'raisedButton',
        #ratio: r'ratio',
        #resetKnob: r'resetKnob',
        #responsiveWidth: r'responsiveWidth',
        #rows: r'rows',
        #scroll: r'scroll',
        #secondaryProgress: r'secondaryProgress',
        #secondaryRatio: r'secondaryRatio',
        #selected: r'selected',
        #selectionSelect: r'selectionSelect',
        #slow: r'slow',
        #snaps: r'snaps',
        #src: r'src',
        #tapAction: r'tapAction',
        #text: r'text',
        #togglePanel: r'togglePanel',
        #tokenList: r'tokenList',
        #track: r'track',
        #trackEnd: r'trackEnd',
        #trackStart: r'trackStart',
        #transition: r'transition',
        #transitionEndAction: r'transitionEndAction',
        #upAction: r'upAction',
        #value: r'value',
        #z: r'z',
      }));
  configureForDeployment([
      i0.upgradeCoreToolbar,
      i1.upgradeCoreSelection,
      i2.upgradeCoreSelector,
      i3.upgradeCoreMenu,
      i4.upgradeCoreMeta,
      i5.upgradeCoreIconset,
      i6.upgradeCoreIcon,
      i7.upgradeCoreItem,
      i8.upgradeCoreHeaderPanel,
      i9.upgradeCoreMediaQuery,
      i10.upgradeCoreDrawerPanel,
      i12.upgradePaperFocusable,
      i13.upgradePaperRipple,
      i14.upgradePaperShadow,
      i15.upgradePaperButton,
      i16.upgradePaperIconButton,
      i17.upgradePaperRadioButton,
      i18.upgradePaperCheckbox,
      i19.upgradeCoreInput,
      i20.upgradePaperInput,
      i21.upgradeCoreTransition,
      i22.upgradeCoreKeyHelper,
      i23.upgradeCoreOverlayLayer,
      i24.upgradeCoreOverlay,
      i25.upgradeCoreTransitionCss,
      i26.upgradePaperToast,
      i27.upgradeCoreRange,
      i28.upgradePaperProgress,
      i29.upgradePaperSlider,
      i30.upgradePaperFab,
      i31.upgradePaperItem,
      i33.upgradePaperMenuButtonOverlay,
      i34.upgradePaperMenuButtonTransition,
      i35.upgradePaperMenuButton,
    ]);
  i37.main();
}
