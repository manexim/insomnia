sources = [
    'Application.vala',
    'Inhibitor.vala',
    'MainWindow.vala',
]

config_data = configuration_data()
config_data.set('APP_ID', meson.project_name())
config_data.set('APP_VERSION', meson.project_version())
config_data.set('GETTEXT_PACKAGE', meson.project_name())
config_data.set('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

config_file = configure_file(
    input: 'Constants.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

executable(
    meson.project_name(),
    sources,
    config_file,
    dependencies: dependencies,
    install: true,
)
