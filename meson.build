project('com.github.manexim.insomnia', 'vala', 'c', version: '1.1.0')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

granite_dep = dependency('granite')
gtk_plus_3_dep = dependency('gtk+-3.0')
libhandy_dep = dependency('libhandy-1', version: '>=1.0.0')

dependencies = [
    granite_dep,
    gtk_plus_3_dep,
    libhandy_dep,
]

subdir('data')
subdir('po')
subdir('src')

meson.add_install_script('meson/post_install.py')
