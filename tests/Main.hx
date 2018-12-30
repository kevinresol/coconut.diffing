import coconut.ui.*;
import coconut.data.*;
import haxe.Timer.delay;
using tink.CoreApi;
using tink.state.Promised;


typedef Rec = Record<{ foo: Int }>;

class Main extends View {
  static function main2() {
    var data = new Data();
    data.observables.details.bind({}, function(o) {
      switch o {
        case Done(details): 
          delay(function() {
            trace('update');
            details.list.first().orNull().value += 1;
          }, 1000);
        default:
      }
    });
            
    // var value = 
    
    coconut.Ui.hxx('
      <Loader value={data.details.map(function(details) return details.list.first().orNull().value)} />
    ').renderInto(js.Browser.document.body);
  }
  static function main() {
    var r = new Rec({ foo: 42});
    // coconut.Ui.hxx('<Main/>').renderInto(js.Browser.document.body);
    coconut.Ui.hxx('
      <main>
        <Blargh>
          <blub>
            Foo: {foo}
            <button onclick={r.update({ foo: r.foo + 1})}>{r.foo}</button>
            <Outer>{r.foo}</Outer>
            <if {r.foo == 42}>
              <video muted></video>
            <else>
              <video>DIV</video>
            </if>
          </blub>
        </Blargh>      
      </main>
    ').renderInto(js.Browser.document.body);
  }
  function render() '<div><Foo depth={5} /></div>';
}


class Loader extends View {
  @:attribute var value:Promised<Int>;
  function render() '
    <div>
      <switch ${value}>
        <case ${Loading}>
          Loading
        <case ${Done(value)}>
          ${Std.string(value)}
        <case ${_}>
      </switch>
    </div>
  ';

  function viewDidMount()
    delay(forceUpdate.bind(), 2000);
}

class Data implements Model {
  @:loaded var details:Details = Future.async(function(cb) delay(cb.bind(new Details()), 1000));
  @:computed var value:Int = switch details {
    case Done(d): d.list.first().orNull().value;
    default: -1;
  }
}

class Details implements Model {
  @:constant var list:List<Wrapped> = @byDefault List.fromArray([new Wrapped()]);
}

class Wrapped implements Model {
  @:editable var value:Int = @byDefault 0;
}

class Foo extends View {
	
  @:state var key:Int = 0;
  @:attribute var depth:Int;

	function render() '
    <if {depth > 0}>
      <Foo depth={depth - 1} />
    <else>
      <div key=${key} onclick=${key++}>Key: $key</div>
    </if>  
  ';
}

class Outer extends View {
  @:attribute var children:Children;
  function render() {
    trace('render Outer');
    return @hxx '<div data-id={viewId}>Outer: {...children} <Inner>{...children}</Inner></div>';
  }
  override function viewDidUpdate()
    trace('updated Outer');
}


class Inner extends View {
  @:attribute var children:Children;
  function render() {
    trace('render Inner');
    return @hxx '<div data-id={viewId}>Inner: {...children}</div>';
  }

  override function viewDidUpdate()
    trace('updated Inner');
}

class Blargh extends View {
  @:attribute function blub(attr:{ foo:String }):Children;
  @:state var hidden:Bool = false;
  function render() '
    <if {!hidden}>
      <>
        <div>1</div>
        <div>2</div>
        {...blub({ foo: "yeah" })}
        <button onclick={hide}>Hide</button>
      </>
    </if>
  ';

  function hide() {
    hidden = true; 
    @in(1) @do hidden = false;
  }

}