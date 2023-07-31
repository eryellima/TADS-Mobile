import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      initialRoute: '/',
      routes: {
        // Rota para a tela iniical
        '/': (context) => TelaInicial(),

        // Rota para a tela de adiionar uma da tarefa
        '/add': (context) => TelaAdicaoTarefa(),

        // Rpta para a tela de edição de tarefa
        'editar': (context) {
          // deveria obter a tarefa passada como argumento ao chmar a rota
          final tarefa = ModalRoute.of(context)?.settings.arguments as String;
          return TelaEdicaoTarefa(tarefa: tarefa);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detalhes') {
          final tarefa = settings.arguments;
          if (tarefa is String) {
            // Rota gerada dinacmicamente para a tela de detalhes da tarefa
            // utiliza o argumento da tarefa passada ao chamar a rota
            return MaterialPageRoute(
              builder: (context) => TelaDetalhesTarefa(tarefa: tarefa),
            );
          }

          // Caso o argumento não seja do tipo String mostra o erro
          return MaterialPageRoute(
            builder: (context) => TelaErroDetalhesTarefa(),
          );
        }

        // Retorna nulo caso nenhuma rota seja encontrada
        return null;
      },
    );
  }
}

class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  List<String> tarefas = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _salvarTarefas() async {
    // Método para salvar as tarefas no SharedPreferences
    await _prefs.setStringList('tarefas', tarefas);
  }

  Future<void> _carregarTarefas() async {
    // Método para carregar as tarefas do SharedPreferences ao inciar o aplcativo
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // Carrega a lista de tarefas do SharedPreferences
      tarefas = _prefs.getStringList('tarefas') ?? [];
    });
  }

  void _adicionarTarefa(String tarefa) {
    // Método para adicionar uma nova tarefa à lista
    setState(() {
      // Adiciona a tarefa a lista
      tarefas.add(tarefa);

      // Salva a lista atualizada no SharedPreferences
      _salvarTarefas();
    });
  }

// Método para remover uma tarefa da lista com base no seu id
  void _removerTarefa(int index) {
    setState(() {
      // Remove a tarefa da lista
      tarefas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: ListView.builder(
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tarefas[index]),
            onTap: () {
              // Navega para a tela de detahless da tarefa
              Navigator.pushNamed(context, '/detalhes',
                  arguments: tarefas[index]);
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Mostra o icone para remover a tarefa
                _removerTarefa(index);
              },
            ),
          );
        },
      ),

      // Botão flutuante para criar numa nova tarefa
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.pushNamed(context, '/add');
          if (resultado != null) {
            _adicionarTarefa(
                resultado as String); // Convertendo o resultado para String
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TelaAdicaoTarefa extends StatefulWidget {
  @override
  _TelaAdicaoTarefaState createState() => _TelaAdicaoTarefaState();
}

class _TelaAdicaoTarefaState extends State<TelaAdicaoTarefa> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';

  void _adicionarTarefa() {
    String tarefa = _controller.text.trim();

    // Verifica se o texto da tarefa não está vazia
    if (tarefa.isNotEmpty) {
      Navigator.pop(context, tarefa);
    } else {
      setState(() {
        _errorMessage = 'O campo de tarefa não pode estar em branco.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          // Campo de texto para a nova tarefa
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Tarefa'),
            ),

            // Botão para adicionar a tarefa
            ElevatedButton(
              onPressed: () {
                final novaTarefa = _controller.text;
                Navigator.pop(context, novaTarefa);
              },
              child: Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaDetalhesTarefa extends StatelessWidget {
  final String tarefa;

  TelaDetalhesTarefa({required this.tarefa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarefa:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(tarefa, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            // Botão que deveria editar a tarefa
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editar', arguments: tarefa);
              },
              child: Text('Editar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaEdicaoTarefa extends StatelessWidget {
  final String tarefa;
  final TextEditingController _controller;

  // Construtor da classe
  TelaEdicaoTarefa({required this.tarefa})
      : _controller = TextEditingController(text: tarefa);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de texto para a edição da tarefa
            TextField(
              // Usamos o controller para vincular o valor do campo ao texto da tarefa
              controller: _controller,
              decoration: InputDecoration(labelText: 'Tarefa'),
            ),

            // Quando o botão "Salvar Edição" é pressionado, a tarefa editada é enviada de volta para a tela anterior
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: Text('Salvar Edição'),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaErroDetalhesTarefa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Erro')),
      body: Center(
        child: Text('Erro: Detalhes da tarefa não disponíveis.'),
      ),
    );
  }
}
