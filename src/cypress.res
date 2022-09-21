type cypress

// A placeholder type for identifying cypress calls that have to be chained from the root
type root

// Using type cy as the identifier for cypress products both chained and not.
type cy<'a>

// Throw away a cypress value
external void: cy<'a> => unit = "%identity"

@val @scope("window")
external cypress: option<cypress> = "Cypress"

// TODO: Not guaranteed to be a string actually? is really Json.t? -AxM
@send external envImpl: (cypress, string) => Js.Null_undefined.t<string> = "env"
let env = (cy, str) => cy->envImpl(str)->Js.Null_undefined.toOption

type window
@send external window: cy<root> => cy<window> = "window"

external return: 'a => cy<'a> = "%identity"

@val @scope("window")
external cy: cy<root> = "cy"

@deriving(abstract)
type optLogTimeout = {
  @optional timeout: int,
  @optional log: bool,
}

@send external documentImpl: (cy<root>, 'opt) => cy<'document> = "document"

// let url = (cy, ~decode=?, ~log=?, ~timeout=?, ()) => {
//   3
// }
// let document = (c, log, ~timeout=?, ()) = {
//   c->documentImpl(optDocument(log, timeout)) 
// }
let document = (cy, ~log=?, ~timeout=?, ()) => {
  cy->documentImpl(optLogTimeout(~log?, ~timeout?))
}

// An opaque type for cypress queries returning an element
// This is ostensibly a jquery object with one value
// TODO: this could be unified with a nice dom rescript library? - AxM
type element

// Using jquery val here
@send external val: element => string = "val"

let value: element => string = %raw(`(e) => e.prop("value")`)
@send external text: element => string = "text"

// TODO: better dom element handling -AxM
let checked: element => bool = %raw(`(e) => e.prop("checked")`)

// An opque type for cypress queries returning multiple elements. is it an array really? - AxM
type elements

type scrollBehavior = [#center | #top | #bottom | #nearest]

@send external clickImpl: (cy<element>, 'opts) => unit = "click"
let click = (cy, ~force=false, ~scrollBehavior: option<scrollBehavior>=?, ()) => {
  cy->clickImpl({"force": force, "scrollBehavior": scrollBehavior->Js.Undefined.fromOption})
}

@send external dblclickImpl: (cy<element>, 'opts) => unit = "dblclick"
let dblclick = (cy, ~force=false, ()) => cy->dblclickImpl({"force": force})

@send external rightclick: cy<element> => unit = "rightclick"

// TODO: Some E variants are contravariant, some covariant - AxM

// Navigation
@send external reload: cy<root> => unit = "reload"
type auth = {
  username: string,
  password: string,
}

@send external visitImpl: (cy<root>, string, 'opt) => cy<root> = "visit"
let visit = (cy, path, ~auth: option<auth>=?, ()) => {
  switch auth {
  | Some(auth) => cy->visitImpl(path, {"auth": auth})
  | _ => cy->visitImpl(path, Js.Undefined.empty)
  }
}
@send external go: (cy<root>, string) => cy<root> = "go"
@send external back: cy<root> => cy<root> = "back"

@deriving(abstract)
type optUrl = {
  @optional decode: bool,
  @optional log: bool,
  @optional timeout: int,
}

@send external urlImpl: (cy<root>, 'opt) => cy<string> = "url"
let url = (cy, ~decode=?, ~log=?, ~timeout=?, ()) => {
  cy->urlImpl(optUrl(~decode?, ~log?, ~timeout?))
}

type position = [
  | #topLeft
  | #top
  | #topRight
  | #left
  | #center
  | #right
  | #bottomLeft
  | #bottom
  | #bottomRight
]
@send external scrollToPosition: (cy<'a>, position) => cy<'a> = "scrollTo"
@send external scrollToXy: (cy<'a>, int, int) => cy<'a> = "scrollTo"

// Evaluation
@send external within: (cy<'e>, unit => 'b) => cy<'e> = "within"

@deriving(abstract)
type flt = {
  @optional force: bool,
  @optional log: bool,
  @optional timeout: int,
}

@send external selectImpl: (cy<element>, string, flt) => cy<element> = "select"
let select = (cy, str, ~force=?, ~log=?, ~timeout=?, ()) => {
  cy->selectImpl(str, flt(~force?, ~log?, ~timeout?, ()))
}

@send external selectIndexImpl: (cy<element>, int, flt) => cy<element> = "select"
let selectIndex = (cy, index, ~force=?, ~log=?, ~timeout=?, ()) => {
  cy->selectIndexImpl(index, flt(~force?, ~log?, ~timeout?, ()))
}

@send external selectManyImpl: (cy<element>, array<string>, flt) => cy<element> = "select"
let selectMany = (cy, strs, ~force=?, ~log=?, ~timeout=?, ()) => {
  cy->selectManyImpl(strs, flt(~force?, ~log?, ~timeout?, ()))
}

@send external selectManyIndexImpl: (cy<element>, array<int>, flt) => cy<element> = "select"
let selectManyIndex = (cy, indexs, ~force=?, ~log=?, ~timeout=?, ()) => {
  cy->selectManyIndexImpl(indexs, flt(~force?, ~log?, ~timeout?, ()))
}

@send external find: (cy<elements>, string) => cy<element> = "find"
@send external findElement: (cy<element>, string) => cy<element> = "find"

// log	true	Displays the command in the Command log
// timeout	defaultCommandTimeout	Time to wait for .first() to resolve before timing out
@send external firstImpl: (cy<elements>, 'opt) => cy<element> = "first" // option<'a>?
let first = (cy, ~log=false, ~timeout=?, ()) => cy->firstImpl(optLogTimeout(~log, ~timeout?))

@send external lastImpl: (cy<elements>, 'opt) => cy<element> = "last" // option<'a>?
let last = (cy, ~log=false, ~timeout=?, ()) => cy->lastImpl(optLogTimeout(~log, ~timeout?))

@send external eqImpl: (cy<elements>, int, 'opt) => cy<element> = "eq" // option<'a>?
let eq = (cy, index, ~log=false, ~timeout=?, ()) => cy->eqImpl(index, optLogTimeout(~log, ~timeout?))

@send external each: (cy<elements>, (element, int, array<element>) => unit) => cy<elements> = "each"
@send external then: (cy<'a>, 'a => 'b) => cy<'b> = "then"
@send external parents: (cy<element>, string) => cy<elements> = "parents"

@deriving(abstract)
type optContains = {
  @optional matchCase: bool, //	true	Check case sensitivity
  @optional log: bool, //	true	Displays the command in the Command log
  @optional timeout: int, //	defaultCommandTimeout	Time to wait for .contains() to resolve before timing out
  @optional includeShadowDom: bool, 	//includeShadowDom config option value	Whether to traverse shadow DOM boundaries and include elements within the shadow DOM in the yielded results.
}

@send external containsRootImpl: (cy<root>, @unwrap [#Re(Js.Re.t) | #Str(string)], 'opts) => cy<element> = "contains"
let containsRoot = (cy, content, ~matchCase=?, ~log=?, ~timeout=?, ~includeShadowDom=?, ()) => {
  cy->containsRootImpl(content, optContains(~matchCase?, ~log?, ~timeout?, ~includeShadowDom?, ()) )
}

@send external containsImpl: (cy<'e>, string, @unwrap [#Re(Js.Re.t) | #Str(string)], optContains) => cy<element> = "contains"
let contains = (cy, selector, content, ~matchCase=?, ~log=?, ~timeout=?, ~includeShadowDom=?, ()) => {
  cy->containsImpl(selector, content, optContains(~matchCase?, ~log?, ~timeout?, ~includeShadowDom?, ()))
}

@send external containsElementImpl: (cy<element> , @unwrap [#Re(Js.Re.t) | #Str(string)], optContains) => cy<element> = "contains"
let containsElement = (cy, content, ~matchCase=?, ~log=?, ~timeout=?, ~includeShadowDom=?, ()) => {
  cy->containsElementImpl(content, optContains(~matchCase?, ~log?, ~timeout?, ~includeShadowDom?, ()))
}

@send external getImpl: (cy<root>, string, 'opts) => cy<elements> = "get"
let get = (cy, string, ~timeout=?, ()) => {
  cy->getImpl(string, {"timeout": timeout})
}

@send external getId: (cy<root>, string) => cy<element> = "get"

@send external titleImpl: (cy<root>, 'opt) => cy<string> = "title"
let title = (cy, ~log=?, ~timeout=?, ()) => cy->titleImpl(optLogTimeout(~log?, ~timeout?))

@send external invoke: (cy<element>, string) => cy<'out> = "invoke"
@send external invoke1: (cy<element>, string, string) => cy<'out> = "invoke"
@send external invoke2: (cy<element>, string, string, string) => cy<'out> = "invoke"
@send external invoke3: (cy<element>, string, string, string, string) => cy<'out> = "invoke"
@send external its: (cy<element>, string) => cy<'out> = "its"

// Operation
@send external checkImpl: (cy<'c>, 'opts) => cy<'c> = "check"
let check = (cy, ~force=false, ()) => cy->checkImpl({"force": force})
// let checkElement = (cy, ~force=false, ()) => cy->checkImpl({"force": force})

@send external uncheckImpl: (cy<'c>, 'opts) => cy<'c> = "uncheck"
let uncheck = (cy, ~force=false, ()) => cy->uncheckImpl({"force": force})

@send external clear: (cy<element>) => cy<element> = "clear"
@send external input: (cy<element>, string) => cy<element> = "type" // Rename to avoid keyword - AxM
@send external blur: (cy<element>) => cy<element> = "blur"

@send external scrollIntoView: (cy<element>, unit) => cy<element> = "scrollIntoView"
@send external triggerImpl: (cy<element>, string, 'opts) => cy<element> = "trigger"
let trigger = (cy, a, ~force=?, ()) => {
  cy->triggerImpl(a, {"force": force})
}

// Logging

type clip = {
  x: int,
  y: int,
  width: int,
  height: int,
}

type padding = (int, int, int, int)

@deriving(abstract)
type optScreenshot = {
  @optional log: bool, //	true	Displays the command in the Command log
  @optional blackout: array<string>, //	[]	Array of string selectors used to match elements that should be blacked out when the screenshot is taken. Does not apply to runner captures.
  @optional capture: [#fullPage | #viewport | #runner ], //	'fullPage'	Which parts of the Test Runner to capture. This value is ignored for element screenshot captures. Valid values are viewport, fullPage, or runner. When viewport, the application under test is captured in the current viewport. When fullPage, the application under test is captured in its entirety from top to bottom. When runner, the entire browser viewport, including the Cypress Command Log, is captured. For screenshots automatically taken on test failure, capture is always coerced to runner.
  @optional clip: clip, //	null	Position and dimensions (in pixels) used to crop the final screenshot image. Should have the following shape: { x: 0, y: 0, width: 100, height: 100 }
  @optional disableTimersAndAnimations: bool, //	true	When true, prevents JavaScript timers (setTimeout, setInterval, etc) and CSS animations from running while the screenshot is taken.
  @optional padding: padding, //	null	Padding used to alter the dimensions of a screenshot of an element. It can either be a number, or an array of up to four numbers using CSS shorthand notation. This property is only applied for element screenshots and is ignored for all other types.
  @optional scale: bool, //	false	Whether to scale the app to fit into the browser viewport. This is always coerced to true when capture is runner.
  @optional timeout: int, //	responseTimeout	Time to wait for .screenshot() to resolve before timing out
  @optional overwrite: bool, //	false	Whether to overwrite duplicate screenshot files with the same file name when saving.
  @optional onBeforeScreenshot: unit => unit, //	null	A callback before a non-failure screenshot is taken. When capturing screenshots of an element, the argument is the element being captured. For other screenshots, the argument is the document.
  @optional onAfterScreenshot: unit => unit, //	null	A callback after a non-failure screenshot is taken. When capturing screenshots of an element, the first argument is the element being captured. For other screenshots, the first argument is the document. The second argument is properties concerning the screenshot, including the path it was saved to and the dimensions of the saved screenshot.0
}

@send external screenshotImpl: (cy<'any>, string, optScreenshot) => cy<string> = "screenshot"
let screenshot = (cy, a, ~log=?, ~timeout=?, ~blackout=?, ~capture=?, ~clip=?, ~disableTimersAndAnimations=?, ~padding=?, ~scale=?, ~overwrite=?, ~onBeforeScreenshot=?, ~onAfterScreenshot=?, ()) => {
  cy->screenshotImpl(a, optScreenshot(~log?, ~blackout?, ~capture?, ~clip?, ~disableTimersAndAnimations?, ~padding?, ~scale?, ~timeout?, ~overwrite?, ~onBeforeScreenshot?, ~onAfterScreenshot?, ()))
}

// Testing
@send external should: (cy<'a>, 'pred) => cy<'a> = "should"
// Should using a comparison value Cmp=Compare
@send external shouldCmp: (cy<'a>, string, 'arg) => cy<'a> = "should"

// Renamed to avoid overwriting boolean not when using open! Cypress
@send external invert: cy<'a> => cy<'a> = "not"

// Cypress utility
@val external config: unit => 'config = "Cypress.config"
@send external pause: cy<root> => unit = "pause"
@send external pauseElements: cy<elements> => cy<elements> = "pause"

@send external log: (cy<'a>, string) => unit = "log"
@send external wait: (cy<root>, int) => unit = "wait"

@send external fixture: (cy<root>, string) => cy<'res> = "fixture"

@send external task: (cy<root>, string, 'opts) => unit = "task"
@send external exec: (cy<root>, string) => unit = "exec"
@send external end: cy<'a> => unit = "end"

type cookie = {value: string}
@send external getCookie: (cy<root>, string) => cy<cookie> = "getCookie"

@send external clearCookies: cy<root> => unit = "clearCookies"

@send external request: (cy<root>, 'opts) => cy<'response> = "request"

type staticresponse = {
  statusCode: int, //	HTTP response status code
  headers: array<string>, //HTTP response headers
  body: string, //Serve a static string/JSON object as the response body
  // fixture	Serve a fixture as the HTTP response body
}

@val external intercept: (string, staticresponse) => unit = "intercept"

// Test framework
@val external describe: (string, @uncurry (unit => unit)) => unit = "describe"
@val external describeSkip: (string, @uncurry (unit => unit)) => unit = "describe.skip"
@val external describeOnly: (string, @uncurry (unit => unit)) => unit = "describe.only"
@val external it: (string, @uncurry (unit => unit)) => unit = "it"
@val external itSkip: (string, @uncurry (unit => unit)) => unit = "it.skip"
@val external itOnly: (string, @uncurry (unit => unit)) => unit = "it.only"

@val external before: (@uncurry (unit => unit)) => unit = "before"
@val external beforeEach: (@uncurry (unit => unit)) => unit = "beforeEach"
@val external after: (@uncurry (unit => unit)) => unit = "after"
@val external afterEach: (@uncurry (unit => unit)) => unit = "afterEach"
