package coconut.diffing;

import tink.state.Observable;

class Widget<Virtual, Real> implements Parent<Virtual, Real> {

  @:noCompletion var _coco_viewMounted:Void->Void;
  @:noCompletion var _coco_viewUpdated:Void->Void;
  @:noCompletion var _coco_viewUnmounting:Void->Void;

  @:noCompletion var _coco_vStructure:ObservableObject<Array<VNode<Virtual, Real>>>;
  @:noCompletion var _coco_lastSnapshot:Array<VNode<Virtual, Real>>;
  @:noCompletion var _coco_lastRender:Rendered<Virtual, Real>;
  @:noCompletion var _coco_invalid:Bool = false;
  @:noCompletion var _coco_parent:Parent<Virtual, Real>;
  @:noCompletion var _coco_root:VRoot<Virtual, Real>;
  @:noCompletion var _coco_link:CallbackLink;
  @:noCompletion var _coco_type:String;
    
  public function new(
    rendered:Observable<VNode<Virtual, Real>>,
    mounted:Void->Void,
    updated:Void->Void,
    unmounting:Void->Void
  ) {
    this._coco_vStructure = rendered.map(function (r) return [r]);
    this._coco_viewMounted = mounted;
    this._coco_viewUpdated = updated;
    this._coco_viewUnmounting = unmounting;    
  }

  function _coco_getRender():Rendered<Virtual, Real> 
    return _coco_lastRender;

  function _coco_invalidate()
    if (!_coco_invalid) {
      _coco_invalid = true;
      if (_coco_parent != null)
        _coco_parent._coco_invalidate();
      _coco_root.schedule(this);
    }

  function _coco_update() if (_coco_invalid) {
    _coco_invalid = false;
    var nuSnapshot = _coco_vStructure.poll().value;
    if (nuSnapshot != _coco_lastSnapshot) {
      _coco_lastSnapshot = nuSnapshot;
      _coco_lastRender = _coco_root.differ.update(_coco_lastRender, nuSnapshot, this, _coco_root);
      _coco_arm();
      _coco_root.afterRendering(_coco_viewUpdated);
    }
  }

  function _coco_arm() {
    _coco_link.dissolve();//you never know
    _coco_link = _coco_vStructure.poll().becameInvalid.handle(_coco_invalidate);
  }

  function _coco_teardown() {
    //TODO: implement
  }

  function _coco_initialize(root:VRoot<Virtual, Real>) {
    _coco_root = root;
    _coco_lastRender = _coco_root.differ.renderAll(
      _coco_lastSnapshot = _coco_vStructure.poll().value,
      _coco_root
    );
    _coco_arm();
    root.afterRendering(_coco_viewMounted);
  }

}