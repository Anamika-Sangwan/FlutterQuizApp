import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const QuizHomePage(),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String category;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  int currentQuestion = 0;
  int score = 0;
  List<int?> userAnswers = [];
  List<int> timeSpent = [];
  int questionStartTime = 0;
  bool quizCompleted = false;

  final List<Question> questions = [
    Question(
      question: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctAnswer: 2,
      category: 'Geography',
    ),
    Question(
      question: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      correctAnswer: 1,
      category: 'Science',
    ),
    Question(
      question: 'Who painted the Mona Lisa?',
      options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Rembrandt'],
      correctAnswer: 2,
      category: 'Art',
    ),
    Question(
      question: 'What is the largest mammal in the world?',
      options: ['African Elephant', 'Blue Whale', 'Giraffe', 'Polar Bear'],
      correctAnswer: 1,
      category: 'Science',
    ),
    Question(
      question: 'In which year did World War II end?',
      options: ['1943', '1944', '1945', '1946'],
      correctAnswer: 2,
      category: 'History',
    ),
  ];

  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(questions.length, null);
    timeSpent = List.filled(questions.length, 0);
    questionStartTime = DateTime.now().millisecondsSinceEpoch;
  }

  void selectAnswer(int selectedIndex) {
    int timeTaken = (DateTime.now().millisecondsSinceEpoch - questionStartTime) ~/ 1000;

    setState(() {
      userAnswers[currentQuestion] = selectedIndex;
      timeSpent[currentQuestion] = timeTaken;

      if (selectedIndex == questions[currentQuestion].correctAnswer) {
        score++;
      }

      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        questionStartTime = DateTime.now().millisecondsSinceEpoch;
      } else {
        quizCompleted = true;
      }
    });
  }

  void resetQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      userAnswers = List.filled(questions.length, null);
      timeSpent = List.filled(questions.length, 0);
      quizCompleted = false;
      questionStartTime = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          centerTitle: true,
        ),
        body: ResultAnalysisPage(
          score: score,
          totalQuestions: questions.length,
          questions: questions,
          userAnswers: userAnswers,
          timeSpent: timeSpent,
          onRestart: resetQuiz,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${currentQuestion + 1}/${questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                questions[currentQuestion].category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              questions[currentQuestion].question,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(
              questions[currentQuestion].options.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onPressed: () => selectAnswer(index),
                  child: Text(
                    questions[currentQuestion].options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultAnalysisPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Question> questions;
  final List<int?> userAnswers;
  final List<int> timeSpent;
  final VoidCallback onRestart;

  const ResultAnalysisPage({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.userAnswers,
    required this.timeSpent,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;
    int totalTime = timeSpent.reduce((a, b) => a + b);
    int avgTime = totalTime ~/ totalQuestions;

    Map<String, int> categoryScores = {};
    Map<String, int> categoryTotals = {};

    for (int i = 0; i < questions.length; i++) {
      String cat = questions[i].category;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + 1;
      if (userAnswers[i] == questions[i].correctAnswer) {
        categoryScores[cat] = (categoryScores[cat] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    percentage >= 70 ? Icons.emoji_events : Icons.flag,
                    size: 64,
                    color: percentage >= 70 ? Colors.amber : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    percentage >= 70 ? 'Great Job!' : 'Keep Learning!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$score / $totalQuestions',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('Total Time', '${totalTime}s'),
                      _buildMetric('Avg Time', '${avgTime}s'),
                      _buildMetric('Accuracy', '${percentage.toStringAsFixed(0)}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...categoryTotals.entries.map((entry) {
                    int catScore = categoryScores[entry.key] ?? 0;
                    double catPercentage = (catScore / entry.value) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('$catScore/${entry.value}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: catPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              catPercentage >= 70 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(questions.length, (index) {
                    bool isCorrect = userAnswers[index] == questions[index].correctAnswer;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Q${index + 1}: ${questions[index].question}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Your answer: ${questions[index].options[userAnswers[index]!]}'),
                            if (!isCorrect)
                              Text(
                                'Correct answer: ${questions[index].options[questions[index].correctAnswer]}',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                            Text('Time: ${timeSpent[index]}s', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRestart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Restart Quiz', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}