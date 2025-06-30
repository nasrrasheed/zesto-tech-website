import SwiftUI
import CoreData

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdDate, ascending: false)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    @State private var selectedProject: Project?
    @State private var searchText = ""
    
    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return Array(projects)
        } else {
            return projects.filter { project in
                (project.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (project.customer?.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (project.projectDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search projects...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Projects List
                List(filteredProjects, id: \.id, selection: $selectedProject) { project in
                    ProjectRowView(project: project)
                        .tag(project)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Projects (\(projects.count))")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { /* Add new project */ }) {
                        Image(systemName: "plus")
                    }
                    .disabled(!authManager.hasPermission(.editProjects))
                    .help("Add Project")
                }
            }
        } detail: {
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                ContentUnavailableView(
                    "Select a Project",
                    systemImage: "folder",
                    description: Text("Choose a project from the list to view details")
                )
            }
        }
    }
}

struct ProjectRowView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name ?? "Unnamed Project")
                .font(.headline)
                .lineLimit(1)
            
            if let customer = project.customer?.name {
                Text(customer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if let description = project.projectDescription, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(project.status ?? "Unknown")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor(project.status ?? "Unknown"))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Spacer()
                
                if let date = project.createdDate {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active", "in progress":
            return .green
        case "completed":
            return .blue
        case "on hold":
            return .orange
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(project.name ?? "Unnamed Project")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Project details will be implemented here")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Project Details")
    }
}

#Preview {
    ProjectsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(AuthenticationManager())
}