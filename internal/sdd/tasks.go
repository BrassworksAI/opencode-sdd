package sdd

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"

	"github.com/BurntSushi/toml"
)

type TaskStatus string

const (
	TaskPending    TaskStatus = "pending"
	TaskInProgress TaskStatus = "in_progress"
	TaskComplete   TaskStatus = "complete"
)

type Task struct {
	Title        string     `toml:"title"`
	Description  string     `toml:"description"`
	Status       TaskStatus `toml:"status"`
	Requirements []string   `toml:"requirements"`
}

type Tasks struct {
	Task map[string]*Task `toml:"task"`
}

func NewTasks() *Tasks {
	return &Tasks{
		Task: make(map[string]*Task),
	}
}

func LoadTasks(changeDir string) (*Tasks, error) {
	path := filepath.Join(changeDir, "tasks.toml")

	if _, err := os.Stat(path); os.IsNotExist(err) {
		return NewTasks(), nil
	}

	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading tasks.toml: %w", err)
	}

	var tasks Tasks
	if err := toml.Unmarshal(data, &tasks); err != nil {
		return nil, fmt.Errorf("parsing tasks.toml: %w", err)
	}

	if tasks.Task == nil {
		tasks.Task = make(map[string]*Task)
	}

	return &tasks, nil
}

func (t *Tasks) Save(changeDir string) error {
	path := filepath.Join(changeDir, "tasks.toml")

	f, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("creating tasks.toml: %w", err)
	}
	defer f.Close()

	encoder := toml.NewEncoder(f)
	if err := encoder.Encode(t); err != nil {
		return fmt.Errorf("encoding tasks.toml: %w", err)
	}

	return nil
}

func (t *Tasks) Add(shortName string, task *Task) error {
	if _, exists := t.Task[shortName]; exists {
		return fmt.Errorf("task %q already exists", shortName)
	}
	if task.Status == "" {
		task.Status = TaskPending
	}
	t.Task[shortName] = task
	return nil
}

func (t *Tasks) Get(shortName string) (*Task, bool) {
	task, exists := t.Task[shortName]
	return task, exists
}

func (t *Tasks) Start(shortName string) error {
	task, exists := t.Task[shortName]
	if !exists {
		return fmt.Errorf("task %q not found", shortName)
	}
	task.Status = TaskInProgress
	return nil
}

func (t *Tasks) Complete(shortName string) error {
	task, exists := t.Task[shortName]
	if !exists {
		return fmt.Errorf("task %q not found", shortName)
	}
	task.Status = TaskComplete
	return nil
}

func (t *Tasks) List() []string {
	names := make([]string, 0, len(t.Task))
	for name := range t.Task {
		names = append(names, name)
	}
	sort.Strings(names)
	return names
}

func (t *Tasks) Stats() (total, complete, inProgress, pending int) {
	for _, task := range t.Task {
		total++
		switch task.Status {
		case TaskComplete:
			complete++
		case TaskInProgress:
			inProgress++
		case TaskPending:
			pending++
		}
	}
	return
}

func (t *Tasks) CurrentTask() (string, *Task) {
	for name, task := range t.Task {
		if task.Status == TaskInProgress {
			return name, task
		}
	}
	return "", nil
}

func (t *Tasks) AllComplete() bool {
	for _, task := range t.Task {
		if task.Status != TaskComplete {
			return false
		}
	}
	return len(t.Task) > 0
}
