import 'package:flutter/material.dart';

class FilterCarousel extends StatefulWidget {
  final ValueChanged<String>
      onFilterSelected; // Função de retorno de chamada para notificar a seleção do filtro

  const FilterCarousel({Key? key, required this.onFilterSelected})
      : super(key: key);

  @override
  _FilterCarouselState createState() => _FilterCarouselState();
}

class _FilterCarouselState extends State<FilterCarousel> {
  String selectedFilter = 'Geral';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Wrap(
              spacing: 8,
              children: [
                buildFilterItem('Geral'),
                buildFilterItem('Comida'),
                buildFilterItem('Roupa'),
                buildFilterItem('Ganhos'),
                buildFilterItem('Outros'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildFilterItem(String filter) {
    final bool isSelected = filter == selectedFilter;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
        widget.onFilterSelected(
            filter); // Invoca a função de retorno de chamada passando o filtro selecionado
      },
      child: Container(
        height: 50,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.6)
              : Theme.of(context).colorScheme.secondary,
        ),
        child: Center(
          child: Text(
            filter,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
