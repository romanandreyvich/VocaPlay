import SwiftUI

struct GroupsListView: View {
    var viewModel: AppViewModel
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var newGroupLanguage: Language = .english
    @State private var groupToDelete: WordGroup?
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.groups.isEmpty {
                    ContentUnavailableView(
                        "Нет групп",
                        systemImage: "folder",
                        description: Text("Создайте новую группу для начала изучения слов")
                    )
                } else {
                    ForEach(viewModel.groups) { group in
                        NavigationLink(destination: WordListView(viewModel: viewModel, group: group)) {
                            GroupRowView(group: group)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                groupToDelete = group
                                showingDeleteAlert = true
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Группы слов")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newGroupName = ""
                        newGroupLanguage = .english
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                NavigationStack {
                    Form {
                        Section("Название группы") {
                            TextField("Введите название", text: $newGroupName)
                        }
                        Section("Язык") {
                            Picker("Выберите язык", selection: $newGroupLanguage) {
                                ForEach(Language.allCases, id: \.self) { language in
                                    Text("\(language.flag) \(language.rawValue)")
                                        .tag(language)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .navigationTitle("Новая группа")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Отмена") {
                                showingAddGroup = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Создать") {
                                if !newGroupName.isEmpty {
                                    viewModel.addGroup(name: newGroupName, language: newGroupLanguage)
                                    showingAddGroup = false
                                }
                            }
                            .disabled(newGroupName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(300)])
            }
            .alert("Удалить группу?", isPresented: $showingDeleteAlert) {
                Button("Удалить", role: .destructive) {
                    if let group = groupToDelete {
                        viewModel.deleteGroup(group)
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Все слова в этой группе будут удалены")
            }
        }
    }
}

struct GroupRowView: View {
    let group: WordGroup

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                Text("\(group.language.flag) \(group.language.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(group.wordCount) слов")
                    .font(.caption)
                if group.learnedCount > 0 {
                    Text("\(group.learnedCount) изучено")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
