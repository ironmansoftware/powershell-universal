import { Input } from '@material-ui/core'

export default function EditableCell({
	cell: { value },
	row: { index },
	column: { id },
	updateData,
	inputProps,
}) {
	const onChange = (event) => {
		updateData(index, id, event.target.value)
	}

	return <Input {...inputProps} value={value} onChange={onChange} />
}