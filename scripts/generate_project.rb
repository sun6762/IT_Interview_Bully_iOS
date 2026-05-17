require 'fileutils'
require 'rexml/document'
require 'xcodeproj'

PROJECT_NAME = 'IT_Interview_Bully'.freeze
PROJECT_PATH = "#{PROJECT_NAME}.xcodeproj".freeze
APP_BUNDLE_ID = 'com.bobo.ITInterviewBully'.freeze
TEST_BUNDLE_ID = 'com.bobo.ITInterviewBullyTests'.freeze

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastSwiftUpdateCheck'] = '1640'
project.root_object.attributes['LastUpgradeCheck'] = '1640'

app_target = project.new_target(:application, PROJECT_NAME, :ios, '13.0')
tests_target = project.new_target(:unit_test_bundle, "#{PROJECT_NAME}Tests", :ios, '13.0')

app_target.product_reference.name = "#{PROJECT_NAME}.app"
tests_target.product_reference.name = "#{PROJECT_NAME}Tests.xctest"

[app_target, tests_target].each do |target|
  target.build_configurations.each do |config|
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    config.build_settings['ENABLE_TESTABILITY'] = config.name == 'Debug' ? 'YES' : 'NO'
  end
end

app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = APP_BUNDLE_ID
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['INFOPLIST_FILE'] = "#{PROJECT_NAME}/Resources/Info.plist"
  config.build_settings['ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS'] = 'NO'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_ASSET_PATHS'] = '""'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
end

tests_target.add_dependency(app_target)
tests_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = TEST_BUNDLE_ID
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['INFOPLIST_FILE'] = "#{PROJECT_NAME}Tests/Info.plist"
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/IT_Interview_Bully.app/IT_Interview_Bully'
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @loader_path/Frameworks'
end

main_group = project.main_group
app_group = main_group.new_group(PROJECT_NAME, PROJECT_NAME)
tests_group = main_group.new_group("#{PROJECT_NAME}Tests", "#{PROJECT_NAME}Tests")
scripts_group = main_group.new_group('scripts', 'scripts')
scripts_group.new_file('generate_project.rb')
scripts_group.new_file('swiftlint.sh')

def ensure_group(parent, name, path = name)
  parent.children.find { |child| child.isa == 'PBXGroup' && child.display_name == name } || parent.new_group(name, path)
end

def ensure_group_path(root_group, components)
  components.reduce(root_group) do |parent, component|
    ensure_group(parent, component)
  end
end

[
  %w[App],
  %w[Presentation Common Markdown],
  %w[Presentation QuestionList],
  %w[Presentation QuestionDetail],
  %w[ViewModels],
  %w[Domain Models],
  %w[Domain Repositories],
  %w[Data Errors],
  %w[Data Models],
  %w[Data Repositories],
  %w[Data Services],
  %w[Resources Assets.xcassets],
  %w[Resources Base.lproj],
  %w[Resources markdown]
].each do |components|
  ensure_group_path(app_group, components)
end

[
  %w[Fixtures],
  %w[Fixtures markdown]
].each do |components|
  ensure_group_path(tests_group, components)
end

def add_file_to_phase(target, root_group, relative_path, phase)
  components = relative_path.split('/')
  file_name = components.pop
  parent_group = components.empty? ? root_group : ensure_group_path(root_group, components)
  file_ref = parent_group.new_file(file_name)
  phase.add_file_reference(file_ref)
end

def add_source_files(target, root_group, relative_paths)
  relative_paths.each do |path|
    add_file_to_phase(target, root_group, path, target.source_build_phase)
  end
end

def add_resource_files(target, root_group, relative_paths)
  relative_paths.each do |path|
    add_file_to_phase(target, root_group, path, target.resources_build_phase)
  end
end

add_source_files(
  app_target,
  app_group,
  [
    'App/AppDelegate.swift',
    'App/SceneDelegate.swift',
    'App/AppDIContainer.swift',
    'Presentation/Common/LoadableState.swift',
    'Presentation/Common/LoadingStateView.swift',
    'Presentation/Common/Markdown/MarkdownRenderableView.swift',
    'Presentation/Common/Markdown/MarkdownViewController.swift',
    'Presentation/Common/Markdown/MarkdownViewContainer.swift',
    'Presentation/QuestionList/QuestionListView.swift',
    'Presentation/QuestionDetail/QuestionDetailView.swift',
    'ViewModels/QuestionListViewModel.swift',
    'ViewModels/QuestionDetailViewModel.swift',
    'Domain/Models/InterviewCategory.swift',
    'Domain/Models/InterviewQuestionSummary.swift',
    'Domain/Models/InterviewQuestionDetail.swift',
    'Domain/Repositories/InterviewRepository.swift',
    'Data/Errors/InterviewRepositoryError.swift',
    'Data/Models/InterviewIndex.swift',
    'Data/Services/BundleResourceLoader.swift',
    'Data/Repositories/BundleInterviewRepository.swift'
  ]
)

add_resource_files(
  app_target,
  app_group,
  [
    'Resources/Base.lproj/LaunchScreen.storyboard',
    'Resources/Assets.xcassets',
    'Resources/interview_index.json',
    'Resources/markdown/runtime-method-swizzling.md',
    'Resources/markdown/memory-retain-cycle.md'
  ]
)

add_source_files(
  tests_target,
  tests_group,
  [
    'InterviewRepositoryTests.swift',
    'QuestionDetailViewModelTests.swift'
  ]
)

add_resource_files(
  tests_target,
  tests_group,
  [
    'Fixtures/test_interview_index.json',
    'Fixtures/invalid_interview_index.json',
    'Fixtures/markdown/sample-question.md'
  ]
)

project.frameworks_group ||= main_group.new_group('Frameworks')

project.save

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app_target, tests_target)
scheme.launch_action.buildable_product_runnable = Xcodeproj::XCScheme::BuildableProductRunnable.new(app_target)
scheme.save_as(PROJECT_PATH, PROJECT_NAME, true)

scheme_path = File.join(PROJECT_PATH, 'xcshareddata', 'xcschemes', "#{PROJECT_NAME}.xcscheme")
doc = REXML::Document.new(File.read(scheme_path))

script_text = <<~SCRIPT
  if [ -x "$SRCROOT/scripts/local_quality_gate.sh" ]; then
    "$SRCROOT/scripts/local_quality_gate.sh"
  else
    echo "warning: scripts/local_quality_gate.sh not found or not executable."
  fi
SCRIPT

buildable_attributes = {
  'BuildableIdentifier' => 'primary',
  'BlueprintIdentifier' => app_target.uuid,
  'BuildableName' => "#{PROJECT_NAME}.app",
  'BlueprintName' => PROJECT_NAME,
  'ReferencedContainer' => "container:#{PROJECT_NAME}.xcodeproj"
}

add_pre_actions = lambda do |action_node|
  action_node.delete_element('PreActions')
  pre_actions = action_node.add_element('PreActions')
  execution_action = pre_actions.add_element('ExecutionAction', {
    'ActionType' => 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction'
  })

  action_content = execution_action.add_element('ActionContent', {
    'title' => 'Local Quality Gate',
    'scriptText' => script_text
  })

  env_buildable = action_content.add_element('EnvironmentBuildable')
  env_buildable.add_element('BuildableReference', buildable_attributes)
end

launch_action = doc.root.elements['LaunchAction']
archive_action = doc.root.elements['ArchiveAction']
add_pre_actions.call(launch_action) if launch_action
add_pre_actions.call(archive_action) if archive_action

File.write(scheme_path, doc.to_s)
