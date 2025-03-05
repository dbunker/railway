from nicegui import ui

# Create any pages/routes
@ui.page('/')
def index_page():
    ui.label('Hello from a module!')

def main():
    # All pages are already defined above. Just run the UI now.
    ui.run()  # blocks until the app is closed