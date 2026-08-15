import 'package:get/get.dart';

/// Every user-facing string, in English and Khmer.
///
/// The key **is the English sentence**. Two reasons that is worth the slightly
/// longer lines:
///
/// * `'Delete user'.tr` reads as what will appear on screen, so a screen can be
///   understood without opening this file
/// * a key that is missing from both maps falls through and GetX prints the key
///   itself — which is already correct English, instead of `delete_user`
///
/// `@name` markers are filled in at the call site with `trParams`:
/// ```dart
/// '@name deleted'.trParams(<String, String>{'name': user.displayName});
/// ```
///
/// Wired up in `main.dart`:
/// ```dart
/// translations: Languages(),
/// locale: const Locale('km', 'KH'),
/// fallbackLocale: const Locale('en', 'US'),
/// ```
/// Switch at runtime with `Get.updateLocale(const Locale('en', 'US'))`.
///
/// NOTE: the Khmer below was written for this project and has not been reviewed
/// by a native speaker. Have someone check it before real users see it.
class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{
    'en_US': <String, String>{
      // --- Common ---
      'GetX Basic': 'GetX Basic',
      'Cancel': 'Cancel',
      'Confirm': 'Confirm',
      'Delete': 'Delete',
      'Edit': 'Edit',
      'Update': 'Update',
      'Retry': 'Retry',
      'Done': 'Done',
      'Info': 'Info',
      'Something went wrong': 'Something went wrong',
      'Loading...': 'Loading...',
      'N/A': '—',

      // --- Auth ---
      'Welcome back': 'Welcome back',
      'Sign in to your account': 'Sign in to your account',
      'Create your account': 'Create your account',
      'Login': 'Login',
      'Logout': 'Logout',
      'Register': 'Register',
      "Don't have an account?": "Don't have an account? Register",
      'Username': 'Username',
      'Username (email)': 'Username (email)',
      'Password': 'Password',
      'Nickname': 'Nickname',
      'Nickname (optional)': 'Nickname (optional)',
      'The server generates one if you leave this empty':
          'The server generates one if you leave this empty',
      'At least 8 characters with an uppercase, a lowercase, a number and a symbol.':
          'At least 8 characters with an uppercase, a lowercase, a number and a symbol.',
      'Login failed': 'Login failed',
      'Registration failed': 'Registration failed',
      'Welcome!': 'Welcome!',
      'You will need to sign in again.': 'You will need to sign in again.',

      // --- User list ---
      'Home': 'Home',
      'Could not load your profile': 'Could not load your profile',
      'Posts': 'Posts',
      'Settings': 'Settings',
      'Preferences': 'Preferences',
      'About': 'About',
      'Version': 'Version',
      'Signed in as': 'Signed in as',
      'Switch between Khmer and English': 'Switch between Khmer and English',
      'Latest posts': 'Latest posts',
      'No posts yet': 'No posts yet',
      'Search by title': 'Search by title',
      'Delete post': 'Delete post',
      'Draft': 'Draft',
      'Edit profile': 'Edit profile',
      'Your account': 'Your account',
      'Update your name and photo': 'Update your name and photo',
      'New post': 'New post',
      'Edit post': 'Edit post',
      'Create post': 'Create post',
      'Title': 'Title',
      'Content': 'Content',
      'Write something…': 'Write something…',
      'My first post': 'My first post',
      'Published': 'Published',
      'Publish': 'Publish',
      'Unpublish': 'Unpublish',
      'Visible to everyone': 'Visible to everyone',
      'Kept as a draft': 'Kept as a draft',
      'Photo uploads after the post is created':
          'Photo uploads after the post is created',
      'Language': 'Language',
      'Connection': 'Connection',
      'Online': 'Online',
      'Offline': 'Offline',
      'No internet connection': 'No internet connection',
      'Users': 'Users',
      'New user': 'New user',
      'Search by username': 'Search by username',
      '@shown of @total shown': '@shown of @total shown',
      'End of list': 'End of list',
      'live': 'live',
      'Live updates connected': 'Live updates connected',
      'Not connected': 'Not connected',
      'No users yet': 'No users yet.\nCreate the first one.',
      'No user matches "@term"': 'No user matches "@term".',
      'Clear search': 'Clear search',
      'Delete user': 'Delete user',
      '@name will be removed from the list':
          '@name will be removed from the list.\n\nThe backend soft-deletes, so the row is kept for audit.',
      '@name deleted': '@name deleted',
      'Enable': 'Enable',
      'Disable': 'Disable',
      'Account enabled': 'Account enabled',
      'Account disabled': 'Account disabled',

      // --- User form ---
      'Edit user': 'Edit user',
      'Create user': 'Create user',
      'Could not save': 'Could not save',
      'Tap to replace the photo': 'Tap to replace the photo',
      'Photo uploads after the user is created':
          'Photo uploads after the user is created',
      'Uploading...': 'Uploading...',
      'Photo updated': 'Photo updated',
      'Upload failed': 'Upload failed',
      'Choose from gallery': 'Choose from gallery',
      'Take a photo': 'Take a photo',
      'Could not open the picker': 'Could not open the picker',
      '@name created': '@name created',
      '@name updated': '@name updated',

      // --- User detail ---
      'User detail': 'User detail',
      'ID': 'ID',
      'Image file': 'Image file',
      'No image uploaded': 'No image uploaded',
      'Created': 'Created',
      'Updated': 'Updated',
      'Enabled': 'Enabled',
      'Disabled': 'Disabled',
      'No user passed': 'No user passed',
      'Created @time': 'Created @time',

      // --- Validation (mirrors the backend's UserValidator) ---
      '@field is required': '@field is required',
      'Username must not exceed @max characters':
          'Username must not exceed @max characters',
      'Username must be a valid email address':
          'Username must be a valid email address',
      'Password must be at least @min characters':
          'Password must be at least @min characters',
      'Password needs an uppercase, a lowercase, a number and a symbol':
          'Password needs an uppercase, a lowercase, a number and a symbol',
      '@field must not exceed @max characters':
          '@field must not exceed @max characters',

      // --- Dates ---
      'just now': 'just now',
      '@n minutes ago': '@n m ago',
      '@n hours ago': '@n h ago',
      '@n days ago': '@n d ago',
    },
    'km_KH': <String, String>{
      // --- Common ---
      'GetX Basic': 'GetX មូលដ្ឋាន',
      'Cancel': 'បោះបង់',
      'Confirm': 'បញ្ជាក់',
      'Delete': 'លុប',
      'Edit': 'កែសម្រួល',
      'Update': 'កែសម្រួល',
      'Retry': 'ព្យាយាមម្ដងទៀត',
      'Done': 'រួចរាល់',
      'Info': 'ព័ត៌មាន',
      'Something went wrong': 'មានបញ្ហាកើតឡើង',
      'Loading...': 'កំពុងផ្ទុក...',
      'N/A': '—',

      // --- Auth ---
      'Welcome back': 'សូមស្វាគមន៍ការត្រឡប់មកវិញ',
      'Sign in to your account': 'ចូលទៅគណនីរបស់អ្នក',
      'Create your account': 'បង្កើតគណនីរបស់អ្នក',
      'Login': 'ចូលទៅប្រើប្រាស់',
      'Logout': 'ចាកចេញ',
      'Register': 'ចុះឈ្មោះ',
      "Don't have an account?": 'មិនមានគណនីមែនទេ? ចុះឈ្មោះ',
      'Username': 'ឈ្មោះអ្នកប្រើប្រាស់',
      'Username (email)': 'ឈ្មោះអ្នកប្រើប្រាស់ (អ៊ីមែល)',
      'Password': 'ពាក្យសម្ងាត់',
      'Nickname': 'ឈ្មោះហៅក្រៅ',
      'Nickname (optional)': 'ឈ្មោះហៅក្រៅ (មិនចាំបាច់)',
      'The server generates one if you leave this empty':
          'ប្រសិនបើទុកទទេ ម៉ាស៊ីនមេនឹងបង្កើតឲ្យ',
      'At least 8 characters with an uppercase, a lowercase, a number and a symbol.':
          'យ៉ាងតិច ៨ តួអក្សរ ដោយមានអក្សរធំ អក្សរតូច លេខ និងសញ្ញាពិសេស។',
      'Login failed': 'ចូលគណនីមិនបានសម្រេច',
      'Registration failed': 'ចុះឈ្មោះមិនបានសម្រេច',
      'Welcome!': 'សូមស្វាគមន៍!',
      'You will need to sign in again.': 'អ្នកនឹងត្រូវចូលគណនីម្ដងទៀត។',

      // --- User list ---
      'Home': 'ទំព័រដើម',
      'Could not load your profile': 'មិនអាចផ្ទុកប្រវត្តិរូបបានទេ',
      'Posts': 'អត្ថបទ',
      'Settings': 'ការកំណត់',
      'Preferences': 'ចំណូលចិត្ត',
      'About': 'អំពី',
      'Version': 'កំណែ',
      'Signed in as': 'បានចូលក្នុងនាម',
      'Switch between Khmer and English': 'ប្ដូររវាងភាសាខ្មែរ និងអង់គ្លេស',
      'Latest posts': 'អត្ថបទថ្មីៗ',
      'No posts yet': 'មិនទាន់មានអត្ថបទ',
      'Search by title': 'ស្វែងរកតាមចំណងជើង',
      'Delete post': 'លុបអត្ថបទ',
      'Draft': 'សេចក្ដីព្រាង',
      'Edit profile': 'កែសម្រួលប្រវត្តិរូប',
      'Your account': 'គណនីរបស់អ្នក',
      'Update your name and photo': 'ធ្វើបច្ចុប្បន្នភាពឈ្មោះ និងរូបភាព',
      'New post': 'អត្ថបទថ្មី',
      'Edit post': 'កែសម្រួលអត្ថបទ',
      'Create post': 'បង្កើតអត្ថបទ',
      'Title': 'ចំណងជើង',
      'Content': 'មាតិកា',
      'Write something…': 'សរសេរអ្វីមួយ…',
      'My first post': 'អត្ថបទដំបូងរបស់ខ្ញុំ',
      'Published': 'បានផ្សាយ',
      'Publish': 'ផ្សាយ',
      'Unpublish': 'ដកការផ្សាយ',
      'Visible to everyone': 'មើលឃើញដោយអ្នកទាំងអស់គ្នា',
      'Kept as a draft': 'រក្សាទុកជាសេចក្ដីព្រាង',
      'Photo uploads after the post is created':
          'រូបភាពនឹងផ្ទុកឡើងបន្ទាប់ពីបង្កើតអត្ថបទ',
      'Language': 'ភាសា',
      'Connection': 'ការតភ្ជាប់',
      'Online': 'មានអ៊ីនធឺណិត',
      'Offline': 'គ្មានអ៊ីនធឺណិត',
      'No internet connection': 'គ្មានការតភ្ជាប់អ៊ីនធឺណិត',
      'Users': 'អ្នកប្រើប្រាស់',
      'New user': 'អ្នកប្រើថ្មី',
      'Search by username': 'ស្វែងរកតាមឈ្មោះអ្នកប្រើប្រាស់',
      '@shown of @total shown': 'បង្ហាញ @shown ក្នុងចំណោម @total',
      'End of list': 'ចប់បញ្ជី',
      'live': 'ផ្ទាល់',
      'Live updates connected': 'បានភ្ជាប់ការធ្វើបច្ចុប្បន្នភាពផ្ទាល់',
      'Not connected': 'មិនបានភ្ជាប់',
      'No users yet': 'មិនទាន់មានអ្នកប្រើប្រាស់។\nសូមបង្កើតដំបូង។',
      'No user matches "@term"': 'រកមិនឃើញអ្នកប្រើដែលត្រូវនឹង "@term" ។',
      'Clear search': 'សម្អាតការស្វែងរក',
      'Delete user': 'លុបអ្នកប្រើប្រាស់',
      '@name will be removed from the list':
          '@name នឹងត្រូវដកចេញពីបញ្ជី។\n\nម៉ាស៊ីនមេលុបបែបទន់ ដូច្នេះទិន្នន័យនៅរក្សាទុកសម្រាប់ត្រួតពិនិត្យ។',
      '@name deleted': 'បានលុប @name',
      'Enable': 'បើក',
      'Disable': 'បិទ',
      'Account enabled': 'គណនីត្រូវបានបើក',
      'Account disabled': 'គណនីត្រូវបានបិទ',

      // --- User form ---
      'Edit user': 'កែសម្រួលអ្នកប្រើប្រាស់',
      'Create user': 'បង្កើតអ្នកប្រើប្រាស់',
      'Could not save': 'មិនអាចរក្សាទុកបាន',
      'Tap to replace the photo': 'ចុចដើម្បីប្ដូររូបភាព',
      'Photo uploads after the user is created':
          'រូបភាពនឹងផ្ទុកឡើងបន្ទាប់ពីបង្កើតអ្នកប្រើប្រាស់',
      'Uploading...': 'កំពុងផ្ទុកឡើង...',
      'Photo updated': 'បានប្ដូររូបភាព',
      'Upload failed': 'ផ្ទុកឡើងមិនបានសម្រេច',
      'Choose from gallery': 'ជ្រើសរើសពីឃ្លាំងរូបភាព',
      'Take a photo': 'ថតរូប',
      'Could not open the picker': 'មិនអាចបើកកម្មវិធីជ្រើសរូបភាព',
      '@name created': 'បានបង្កើត @name',
      '@name updated': 'បានកែប្រែ @name',

      // --- User detail ---
      'User detail': 'ព័ត៌មានលម្អិតអ្នកប្រើប្រាស់',
      'ID': 'លេខសម្គាល់',
      'Image file': 'ឯកសាររូបភាព',
      'No image uploaded': 'មិនទាន់មានរូបភាព',
      'Created': 'បានបង្កើត',
      'Updated': 'បានកែប្រែ',
      'Enabled': 'សកម្ម',
      'Disabled': 'អសកម្ម',
      'No user passed': 'គ្មានទិន្នន័យអ្នកប្រើប្រាស់',
      'Created @time': 'បង្កើត @time',

      // --- Validation ---
      '@field is required': 'ត្រូវការ @field',
      'Username must not exceed @max characters':
          'ឈ្មោះអ្នកប្រើប្រាស់មិនត្រូវលើសពី @max តួអក្សរ',
      'Username must be a valid email address':
          'ឈ្មោះអ្នកប្រើប្រាស់ត្រូវតែជាអ៊ីមែលត្រឹមត្រូវ',
      'Password must be at least @min characters':
          'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច @min តួអក្សរ',
      'Password needs an uppercase, a lowercase, a number and a symbol':
          'ពាក្យសម្ងាត់ត្រូវមានអក្សរធំ អក្សរតូច លេខ និងសញ្ញាពិសេស',
      '@field must not exceed @max characters':
          '@field មិនត្រូវលើសពី @max តួអក្សរ',

      // --- Dates ---
      'just now': 'អម្បាញ់មិញ',
      '@n minutes ago': '@n នាទីមុន',
      '@n hours ago': '@n ម៉ោងមុន',
      '@n days ago': '@n ថ្ងៃមុន',
    },
  };
}
