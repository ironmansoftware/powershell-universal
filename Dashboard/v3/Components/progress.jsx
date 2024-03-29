import React from 'react';
import CircularProgress from '@material-ui/core/CircularProgress';
import LinearProgress from '@material-ui/core/LinearProgress';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
    bar: props => ({
        backgroundColor: props.progressColor ?? null
    }),
    root:  props => ({
        backgroundColor: props.backgroundColor ?? null
    }),
    circular: props => ({
        color: props.progressColor ?? null
    })
}))

export default function Progress(props) {

    const classes = useStyles(props);

    if (props.circular) {
        return <CircularProgress id={props.id} classes={{
            root: classes.circular
        }}/>
    }

    return <div style={{width: '100%'}}><LinearProgress variant={props.variant} value={props.percentComplete} id={props.id} classes={{
        root: classes.root,
        bar: classes.bar
    }}/></div>
}