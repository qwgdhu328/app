const fs = require('fs');
let src = fs.readFileSync('App.js', 'utf8');
const linesCount = src.split('\n').length;
console.log('=== STARTING SLIM ===');
console.log('initial lines:', linesCount);

// EDIT 1 — Add 6 new screen imports after `import { renderRich }`
const renderRichImport = "import { renderRich } from './src/components/RichText';\n";
if (!src.includes(renderRichImport)) throw new Error('EDIT 1 anchor not found');
src = src.replace(
  renderRichImport,
  renderRichImport +
  "import IntroScreen from './src/features/intro/screens/IntroScreen';\n" +
  "import HomeScreen from './src/features/home/screens/HomeScreen';\n" +
  "import ChatScreen from './src/features/chat/screens/ChatScreen';\n" +
  "import ProfileScreen from './src/features/profile/screens/ProfileScreen';\n" +
  "import CommunityScreen from './src/features/community/screens/CommunityScreen';\n" +
  "import InfoScreen from './src/features/info/screens/InfoScreen';\n"
);
console.log('EDIT 1: 6 new screen imports added');

// EDIT 2 — Drop module-level MOODS const
const moodsRegex = /\nconst MOODS = \[\n[\s\S]+?\n\];\n/;
if (!moodsRegex.test(src)) throw new Error('EDIT 2 MOODS not found');
src = src.replace(moodsRegex, '\n');
console.log('EDIT 2: MOODS const dropped');

// EDIT 3 — Drop module-level todayKey + addDays helpers
const todayAddRegex = /\nconst todayKey = \(\) => \{[\s\S]+?const addDays = \(key, delta\) => \{[\s\S]+?\n\};\n/;
if (!todayAddRegex.test(src)) throw new Error('EDIT 3 todayKey/addDays not found');
src = src.replace(todayAddRegex, '\n');
console.log('EDIT 3: todayKey + addDays dropped');

// EDIT 4 — Drop module-level QUICK_REPLY_TEXT
const quickReplyRegex = /\n\/\/ Sentences that a quick-reply chip[\s\S]+?const QUICK_REPLY_TEXT = \{[\s\S]+?\n\};\n/;
if (!quickReplyRegex.test(src)) throw new Error('EDIT 4 QUICK_REPLY_TEXT not found');
src = src.replace(quickReplyRegex, '\n');
console.log('EDIT 4: QUICK_REPLY_TEXT dropped');

// EDIT 5 — Drop the 6 inline screen function blocks + their styles
function dropScreenBlock(name) {
  const startMarker = 'function ' + name + '(';
  const startIdx = src.indexOf('\n' + startMarker);
  if (startIdx === -1) throw new Error('Block ' + name + ' start not found');
  const styleStart = src.indexOf('StyleSheet.create', startIdx);
  if (styleStart === -1) throw new Error('Block ' + name + ' StyleSheet.create not found');
  // Find the matching `});` by counting braces
  let depth = 0;
  let endIdx = styleStart;
  for (let i = styleStart; i < src.length; i++) {
    if (src[i] === '{') depth++;
    else if (src[i] === '}') {
      depth--;
      if (depth === 0) {
        endIdx = i + 2;
        break;
      }
    }
  }
  src = src.slice(0, startIdx) + src.slice(endIdx);
}
dropScreenBlock('IntroScreen');
dropScreenBlock('HomePage');
dropScreenBlock('ChatPage');
dropScreenBlock('ProfilePage');
dropScreenBlock('CommunityPage');
dropScreenBlock('InfoPage');
console.log('EDIT 5: 6 inline screen function blocks dropped');

// EDIT 6 — Drop trailing co + i StyleSheets + tail helpers
const coStart = src.indexOf('\nconst co = StyleSheet.create({');
if (coStart === -1) throw new Error('EDIT 6 co StyleSheet not found');
src = src.slice(0, coStart) + '\n';
console.log('EDIT 6: trailing co + i StyleSheets + tail helpers dropped');

// EDIT 7 — Update render sites in App()
const renderSubs = [
  [/<HomePage\n[\s\S]+?\/>/, "<HomeScreen\n          onNavigate={setActiveTab}\n          onFreeWrite={() => setShowFreeWrite(true)}\n          onPickMood={handlePickMood}\n        />"],
  [/<ChatPage\n[\s\S]+?\/>/, "<ChatScreen\n            onSend={sendMessage}\n            onReset={resetChat}\n            onAcceptConsent={acceptConsent}\n            onQuickPick={handleQuickPick}\n          />"],
  [/<ProfilePage\n[\s\S]+?\/>/, "<ProfileScreen\n            onStartChat={() => setActiveTab('chat')}\n            onJumpToChat={() => setActiveTab('chat')}\n          />"],
  [/<CommunityPage[\s\S]+?\/>/, "<CommunityScreen onNavigate={setActiveTab} />"],
  [/<InfoPage[\s\S]+?\/>/, "<InfoScreen onBack={() => setActiveTab('home')} />"],
];
for (const [re, repl] of renderSubs) {
  if (!re.test(src)) throw new Error('Render site not matched: ' + re);
  src = src.replace(re, repl);
}
console.log('EDIT 7: 6 render sites updated');

fs.writeFileSync('App.js', src);
const finalLines = src.split('\n').length;
console.log('=== SLIM COMPLETE ===');
console.log('FINAL lines:', finalLines);
console.log('SAVED lines:', linesCount - finalLines);
